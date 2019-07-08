require './config/initializers/stripe'
require './app/models/billing_manager/subscription'

module StripeHelpers
  def setup_stripe_subscription(user)
    subscription = BillingManager::Subscription.new(user_id: user.id)
    subscription_params = {
      card_token: stripe_helper.generate_card_token,
      plan: 'pro',
      email: user.email
    }
    subscription.transition_to!(:subscribed, subscription_params)
  end

  def stripe_helper
    StripeMock.create_test_helper
  end

end
