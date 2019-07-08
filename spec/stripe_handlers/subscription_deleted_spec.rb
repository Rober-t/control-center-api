require "spec_helper"
require "./app/models/billing_manager/stripe_handlers/subscription_deleted"
require "./app/models/billing_manager/subscription"

describe BillingManager::StripeHandlers::SubscriptionDeleted do

  before do
    setup_stripe_subscription(current_user)
  end

  describe "#call" do
    it "cancels the user's subscription" do
      event = StripeMock.mock_webhook_event('customer.subscription.deleted', {
        :id => current_user.subscription.subscription_id,
        :plan => { id: "pro" }
      })

      BillingManager::StripeHandlers::SubscriptionDeleted.new.call(event)

      subscription = BillingManager::Subscription.find_by(user_id: current_user.id)

      expect(subscription.state).to eq "canceled"
    end
  end
end
