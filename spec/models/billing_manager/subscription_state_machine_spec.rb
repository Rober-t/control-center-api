require 'spec_helper'
require './app/models/billing_manager/subscription'
require './app/models/billing_manager/subscription_state_machine'

describe BillingManager::SubscriptionStateMachine do

  before(:each) do
    @subscription = BillingManager::Subscription.new(user_id: current_user.id)
    @subscription_params = {
      card_token: stripe_helper.generate_card_token,
      plan: 'pro',
      email: current_user.email
    }
  end

  before do
    allow_any_instance_of(StripeMock::Instance).to receive(:get_card_by_token) {
      StripeMock::Data.mock_card Stripe::Util.symbolize_names({})
    }
  end

  describe "callbacks" do
    describe "from_inactive_to_subscribed" do
      it "creates a new subscription" do
        expect { @subscription.transition_to!(:subscribed, @subscription_params) }.to change {
          BillingManager::Subscription.count
        }.by(1)
      end
    end

    describe "to_saved_card" do
      it "saves card" do
        params = {
          card_token: stripe_helper.generate_card_token,
          email: current_user.email
        }

        expect { @subscription.transition_to!(:saved_card, params) }.to change {
          BillingManager::Subscription.count
        }.by(1)
      end
    end

    describe "from_saved_card_to_subscribed" do
      before do
        params = {
          card_token: stripe_helper.generate_card_token,
          email: current_user.email
        }
        @subscription.transition_to!(:saved_card, params)
      end

      it "subscribes user" do
        expect { @subscription.transition_to!(:subscribed, { plan: "enterprise" } ) }.to change {
          @subscription.reload.plan
        }.to "enterprise"
      end
    end

    describe "to_updated_subscription" do
      before do
        @subscription.transition_to!(:subscribed, @subscription_params)
      end

      skip "updates a subscription" do
        expect(current_user.subscription.plan).to eq "pro"

        expect { @subscription.transition_to!(:updated_subscription, { plan: "enterprise" } ) }.to change {
          @subscription.reload.plan
        }.to "enterprise"
      end
    end

    describe "to_canceled_subscription" do
      before do
        @subscription.transition_to!(:subscribed, @subscription_params)
      end

      it "cancels a subscription" do
        expect(current_user.subscription.cancel_at_period_end).to eq false

        expect { @subscription.transition_to!(:canceled_subscription) }.to change {
          @subscription.reload.cancel_at_period_end
        }.to true
      end
    end

    describe "from_canceled_subscription_to_subscribed" do
      before do
        @subscription.transition_to!(:subscribed, @subscription_params)
        @subscription.transition_to!(:canceled_subscription)
        @subscription.update(state: 'canceled')
      end

      skip "re-subscribes a cancelled subscription" do
        expect(current_user.subscription.state).to eq 'canceled'

        expect { @subscription.transition_to!(:subscribed, { plan: "enterprise" } ) }.to change {
          @subscription.reload.state
        }.to 'active'
      end

      context "when a card_token parameter is present" do
        skip "re-subscribes a canceled_subscription" do
          expect(current_user.subscription.state).to eq 'canceled'

          card_token = stripe_helper.generate_card_token

          expect { @subscription.transition_to!(:subscribed, { plan: "enterprise", card_token: card_token } ) }.to change {
            @subscription.reload.default_card
          }.to "test_cc_6"
        end
      end
    end

    describe "from_updated_subscription_to_updated_subscription" do
      before do
        @subscription.transition_to!(:subscribed, @subscription_params)
      end

      it "updates a subscription" do
        expect(current_user.subscription.plan).to eq "pro"

        expect { @subscription.transition_to!(:updated_subscription, { plan: "enterprise" } ) }.to change {
          @subscription.reload.plan
        }.to "enterprise"
      end
    end

    describe "to_updated_card" do
      before do
        @subscription.transition_to!(:subscribed, @subscription_params)
      end

      skip "updates a subscription's card" do
        expect { @subscription.transition_to!(:updated_card, { card_attributes: { exp_year: 2020 } } ) }.to change {
          Stripe::Customer.retrieve(@subscription.customer_id).sources.data.first.exp_year
        }.to 2020
      end
    end

    describe "to_updated_customer_email" do
      before do
        @subscription.transition_to!(:subscribed, @subscription_params)
      end

      skip "updates a users payment_processor email" do
        expect { @subscription.transition_to!(:updated_customer_email, { email: "test@statesman.com" } ) }.to change {
          Stripe::Customer.retrieve(@subscription.customer_id).email
        }.to "new_email@statesman.com"
      end
    end

    describe "to_updated_customer_via_webhook" do
      before do
        @subscription.transition_to!(:subscribed, @subscription_params)
      end

      it "updates a customers card via webhook payload" do
        event = StripeMock.mock_webhook_event('customer.updated', {
          :id => current_user.subscription.customer_id,
          :default_source => stripe_helper.generate_card_token
        })

        new_card = event.data.object.default_source

        expect(@subscription.default_card).not_to eq new_card

        expect { @subscription.transition_to!(:updated_customer_via_webhook, { default_card: event.data.object.default_source } ) }.to change {
          @subscription.default_card
        }.to new_card
      end
    end

    describe "to_updated_subscription_via_webhook" do
      before do
        @subscription.transition_to!(:subscribed, @subscription_params)
      end

      it "updates a subscription via webhook" do
        expect(current_user.subscription.plan).to eq "pro"

        event = StripeMock.mock_webhook_event('customer.subscription.updated', {
          :id => current_user.subscription.subscription_id,
          :plan => { id: "enterprise" }
        })

        expect { @subscription.transition_to!(:updated_subscription_via_webhook, { payload: event.data.object } ) }.to change {
          @subscription.reload.plan
        }.to "enterprise"
      end
    end

    describe "to_deleted_subscription_via_webhook" do
      before do
        @subscription.transition_to!(:subscribed, @subscription_params)
      end

      it "cancels a subscription via webhook" do
        expect(current_user.subscription.state).to eq 'active'

        event = StripeMock.mock_webhook_event('customer.subscription.deleted', {
          :id => current_user.subscription.subscription_id,
          :plan => { id: current_user.subscription.plan}
        })

        expect { @subscription.transition_to!(:deleted_subscription_via_webhook, { payload: event.data.object } ) }.to change {
          @subscription.reload.state
        }.to 'canceled'
      end
    end

    describe "to_expired_subcription" do
      before do
        @subscription.transition_to!(:subscribed, @subscription_params)
      end

      it "cancels a subscription" do
        expect(current_user.subscription.state).to eq 'active'

        expect { @subscription.transition_to!(:expired_subscription) }.to change {
          @subscription.reload.state
        }.to 'canceled'
      end
    end

    describe "to_deleted_subcription" do
      before do
        @subscription.transition_to!(:subscribed, @subscription_params)
      end

      it "cancels a subscription now" do
        expect(current_user.subscription.state).to eq 'active'

        expect { @subscription.transition_to!(:deleted_subscription) }.to change {
          @subscription.reload.state
        }.to 'canceled'
      end
    end

    describe "from_expired_subcription_to_subscribed" do
      before do
        @subscription.transition_to!(:subscribed, @subscription_params)
        @subscription.transition_to!(:canceled_subscription)
        @subscription.update(state: 'canceled')
      end

      skip "re-subscribes an expired subscription" do
        expect(current_user.subscription.state).to eq 'canceled'

        expect { @subscription.transition_to!(:subscribed, { plan: "enterprise" } ) }.to change {
          @subscription.reload.state
        }.to 'active'
      end

      context "when a card_token parameter is present" do
        skip "re-subscribes a canceled_subscription" do
          expect(current_user.subscription.state).to eq 'canceled'

          card_token = stripe_helper.generate_card_token

          expect { @subscription.transition_to!(:subscribed, { plan: "enterprise", card_token: card_token } ) }.to change {
            @subscription.reload.default_card
          }.to "test_cc_6"
        end
      end
    end

  end
end
