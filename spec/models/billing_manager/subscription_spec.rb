require 'spec_helper'
require './app/models/billing_manager/subscription'

describe BillingManager::Subscription do

  it 'has a valid factory' do
    setup_stripe_subscription(current_user)

    expect(current_user.subscription).to be_valid
  end

  describe '#active?' do
    context 'when state is active' do
      it 'returns true' do
        setup_stripe_subscription(current_user)

        expect(current_user.subscription.active?).to eq true
      end
    end

    context 'when state is inactive' do
      it 'returns false' do
        setup_stripe_subscription(current_user)
        subscription = current_user.subscription

        subscription.update!(state: 'canceled')

        expect(subscription.active?).to eq false
      end
    end
  end

  describe "#create_customer" do
    it "creates a new stripe customer" do
      subject = BillingManager::Subscription.new(user_id: current_user.id).create_customer(current_user.email)

      expect(subject).to eq true
    end

    it "raises a payment processing error for create_customer" do
      custom_error = PaymentProcessingError.new("Testing")

      StripeMock.prepare_error(custom_error, :new_customer)

      expect{ BillingManager::Subscription.new(user_id: current_user.id).create_customer(current_user.email) }.to raise_error { |e|
        expect(e).to be_a PaymentProcessingError
        expect(e.message).to eq("Testing")
      }
    end
  end

  describe "#update_customer_email" do
    skip "updates the customer email" do
      subscription = setup_new_stripe_customer
      cus = Stripe::Customer.retrieve(subscription.customer_id)

      expect(cus.email).not_to eq ("test@test.com")

      subscription.update_customer_email("test@test.com")

      cus = Stripe::Customer.retrieve(subscription.customer_id)
      expect(cus.email).to eq "test@test.com"
    end

    it "raises a payment processing error for update_customer_email" do
      expect{ BillingManager::Subscription.new(user_id: current_user.id).update_customer_email(current_user.email) }.to raise_error { |e|
        expect(e).to be_a PaymentProcessingError
      }
    end
  end

  describe "#save_card" do
    it "creates a new card on stripe" do
      subscription = setup_new_stripe_customer

      card = Stripe::Customer.retrieve(subscription.customer_id).sources.data.first

      expect(subscription.default_card).not_to eq nil
    end

    it "raises a card error for save_card" do
      subscription = BillingManager::Subscription.new(user_id: current_user.id)

      subscription.create_customer(current_user.email)

      StripeMock.prepare_card_error(:card_declined, :create_source)

      expect{ subscription.save_card('invalid_card_token') }.to raise_error { |e|
        expect(e).to be_a CardError
        expect(e.message).to eq("The card was declined")
      }
    end

    it "raises a payment processing error for save_card" do
      subscription = BillingManager::Subscription.new(user_id: current_user.id)

      subscription.create_customer(current_user.email)

      expect{ subscription.save_card('invalid_card_token') }.to raise_error { |e|
        expect(e).to be_a PaymentProcessingError
        expect(e.message).to eq("Invalid token id: invalid_card_token")
      }
    end
  end

  describe "#update_card" do
    it "should update customer's current card details" do
      subscription = setup_new_stripe_customer

      old_card_details = Stripe::Customer.retrieve(subscription.customer_id).sources.data.first

      expect(old_card_details['exp_year']).not_to eq(2050)

      subscription.update_card( { exp_year: 2050 } )

      new_card_details = Stripe::Customer.retrieve(subscription.customer_id).sources.data.first

      expect(new_card_details['exp_year']).to eq(2050)
    end

    it "raises a card error for update_card" do
      subscription = setup_new_stripe_customer

      StripeMock.prepare_card_error(:invalid_expiry_year, :update_source)

      expect{ subscription.update_card( { exp_year: 1960 } ) }.to raise_error { |e|
        expect(e).to be_a CardError
        expect(e.message).to eq("The card's expiration year is invalid")
      }
    end

    it "raises a payment processing error for update_card" do
      subscription = BillingManager::Subscription.new(user_id: current_user.id)

      expect{ subscription.update_card }.to raise_error { |e|
        expect(e).to be_a PaymentProcessingError
        expect(e.message).to eq("No such customer: ")
      }
    end
  end

  describe "#subscribe" do
    it "creates a new stripe subscription" do
      setup_new_stripe_customer

      subscription = BillingManager::Subscription.find_by(user_id: current_user.id)

      expect(subscription.state).to eq 'inactive'

      subscription.subscribe('pro')

      expect(subscription.state).to eq 'active'
      expect(subscription.plan).to eq 'pro'
    end

    context "when a coupon code is supplied" do
      skip "applies the correct discount" do
        setup_new_stripe_customer

        subscription = BillingManager::Subscription.find_by(user_id: current_user.id)

        expect(subscription.state).to eq 'inactive'

        subscription.subscribe("pro", "50OFF1MONTH")

        expect(subscription.state).to eq 'active'
        expect(subscription.coupon_code).to eq "50OFF1MONTH"
      end
    end

    it "raises a payment processing error for subscribe" do
      subscription = BillingManager::Subscription.new(user_id: current_user.id)

      expect{ subscription.subscribe('pro') }.to raise_error { |e|
        expect(e).to be_a PaymentProcessingError
        expect(e.message).to eq("No such customer: ")
      }
    end
  end

  describe "#update_subscription" do
    it "updates stripe subscription" do
      setup_new_stripe_customer
      current_user.subscription.subscribe("pro")

      subscription = BillingManager::Subscription.find_by(user_id: current_user.id)

      expect(subscription.plan).to eq "pro"

      subscription.update_subscription("enterprise")

      expect(subscription.plan).to eq "enterprise"
    end

    context "when a coupon code is supplied" do
      it "applies the correct discount" do
        setup_new_stripe_customer

        current_user.subscription.subscribe("pro")

        subscription = BillingManager::Subscription.find_by(user_id: current_user.id)

        expect(subscription.plan).to eq "pro"

        subscription.update_subscription("enterprise", "50OFF1MONTH")

        expect(subscription.plan).to eq "enterprise"
        expect(subscription.coupon_code).to eq "50OFF1MONTH"
      end
    end

    it "raises a payment processing error for update_subscription" do
      subscription = BillingManager::Subscription.new(user_id: current_user.id)

      expect{ subscription.update_subscription('pro') }.to raise_error { |e|
        expect(e).to be_a PaymentProcessingError
        expect(e.message).to eq("No such customer: ")
      }
    end
  end

  describe "#cancel_subscription_at_period_end" do
    it "cancels stripe subscription" do
      setup_new_stripe_customer

      current_user.subscription.subscribe("pro")

      subscription = BillingManager::Subscription.find_by(user_id: current_user.id)

      expect(subscription.state).to eq 'active'

      subscription.cancel_subscription_at_period_end

      expect(subscription.cancel_at_period_end).to eq true
    end

    it "raises a payment processing error for update_subscription" do
      subscription = BillingManager::Subscription.new(user_id: current_user.id)

      expect{ subscription.cancel_subscription_at_period_end }.to raise_error { |e|
        expect(e).to be_a PaymentProcessingError
        expect(e.message).to eq("No such customer: ")
      }
    end
  end

  describe "#cancel_subscription_now" do
    it "cancels the user's subscription immediately" do
      setup_new_stripe_customer

      current_user.subscription.subscribe("pro")

      subscription = BillingManager::Subscription.find_by(user_id: current_user.id)

      expect(subscription.state).to eq 'active'

      subscription.cancel_subscription_now

      expect(subscription.state).to eq 'canceled'
    end

    it "raises a payment processing error for update_subscription" do
      subscription = BillingManager::Subscription.new(user_id: current_user.id)

      expect{ subscription.cancel_subscription_now }.to raise_error { |e|
        expect(e).to be_a PaymentProcessingError
        expect(e.message).to eq("No such customer: ")
      }
    end
  end

  private

  def setup_new_stripe_customer
    subscription = BillingManager::Subscription.new(user_id: current_user.id)
    subscription.create_customer(current_user.email)
    card_token = StripeMock.generate_card_token(last4: "1891", exp_year: 2016)
    subscription.save_card(card_token)
    subscription
  end
end
