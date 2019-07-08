require "spec_helper"
require "./app/models/billing_manager/stripe_handlers/customer_updated"
require "./app/models/billing_manager/stripe_handlers/subscription_updated"
require "./app/models/billing_manager/stripe_handlers/subscription_deleted"

describe "Stripe" do

  before(:each) do
    set_auth_header current_user
  end

  before do
    setup_stripe_subscription(current_user)
  end

  describe "POST stripe/billing_events", autodoc: true do
    skip "updates subscription" do
      event = StripeMock.mock_webhook_event('customer.updated', {
        :id => current_user.subscription.customer_id,
        :default_source => stripe_helper.generate_card_token
      })

      post "stripe/billing_events", event.to_hash

      expect(last_response.status).to eq 201
      expect(last_response.header).to be_valid_json

      subscription = BillingManager::Subscription.find_by(user_id: current_user.id)
      expect(subscription.reload.default_card).to eq event.data.object.default_source
    end

    it "updates customer" do
      event = StripeMock.mock_webhook_event('customer.subscription.updated', {
        :id => current_user.subscription.subscription_id,
        :plan => { id: "pro" }
      })

      post "stripe/billing_events", event.to_hash

      expect(last_response.status).to eq 201
      expect(last_response.header).to be_valid_json

      subscription = BillingManager::Subscription.find_by(user_id: current_user.id)
      expect(subscription.reload.plan).to eq "pro"
    end

    skip "deletes subscription" do
      event = StripeMock.mock_webhook_event('customer.subscription.deleted', {
        :id => current_user.subscription.subscription_id,
        :plan => { id: "pro" }
      })

      post "stripe/billing_events", event.to_hash

      expect(last_response.status).to eq 201
      expect(last_response.header).to be_valid_json

      subscription = BillingManager::Subscription.find_by(user_id: current_user.id)
      expect(subscription.reload.state).to eq 'canceled'
    end
  end

end
