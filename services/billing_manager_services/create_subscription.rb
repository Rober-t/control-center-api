require './lib/service'
require './app/models/billing_manager/subscription'
require './app/models/organisation_manager/user'

module BillingManagerServices
  class CreateSubscriptionService < Service

    def execute
      params.merge!(email: current_user.email)
      subscription = BillingManager::Subscription.new(user_id: current_user.id)
      subscription.transition_to!(:subscribed, params.to_h)
      subscription
    end

  end
end
