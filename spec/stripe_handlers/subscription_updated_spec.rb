require "spec_helper"
require "./app/models/billing_manager/stripe_handlers/subscription_updated"
require "./app/models/billing_manager/subscription"

describe BillingManager::StripeHandlers::SubscriptionUpdated do

  before do
    setup_stripe_subscription(current_user)
  end

  describe "#call" do
    it "updates the user's subscription" do
      event = StripeMock.mock_webhook_event('customer.subscription.updated', {
        :id => current_user.subscription.subscription_id,
        :plan => { id: "pro" }
      })

      BillingManager::StripeHandlers::SubscriptionUpdated.new.call(event)

      subscription = BillingManager::Subscription.find_by(user_id: current_user.id)

      expect(subscription.plan).to eq "pro"
    end
  end
end

