require './lib/service'
require './app/models/billing_manager/subscription'

module BillingManagerServices
  class UpdateSubscriptionService < Service

    def execute
      subscription = current_user.subscription
      subscription.transition_to!(:updated_subscription, params.to_h)
      subscription
    end

  end
end
