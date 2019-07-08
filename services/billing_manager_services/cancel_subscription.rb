require './lib/service'

module BillingManagerServices
  class CancelSubscriptionService < Service

    def execute
      subscription = current_user.subscription
      subscription.transition_to!(:canceled_subscription)
    end

  end
end
