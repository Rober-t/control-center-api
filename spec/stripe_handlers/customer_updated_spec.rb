require "spec_helper"
require "./app/models/billing_manager/stripe_handlers/customer_updated"
require "./app/models/billing_manager/subscription"

describe BillingManager::StripeHandlers::CustomerUpdated do

  before do
    setup_stripe_subscription(current_user)
  end

  describe "#call" do
    it "updates the user's default card" do
      event = StripeMock.mock_webhook_event('customer.updated', {
        :id => current_user.subscription.customer_id,
        :default_source => stripe_helper.generate_card_token
      })

      BillingManager::StripeHandlers::CustomerUpdated.new.call(event)

      subscription = BillingManager::Subscription.find_by(user_id: current_user.id)

      expect(subscription.default_card).to eq event.data.object.default_source
    end
  end
end
