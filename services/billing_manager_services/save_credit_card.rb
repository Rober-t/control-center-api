require './lib/service'
require './app/models/billing_manager/subscription'

module BillingManagerServices
  class SaveCreditCardService < Service

    def execute
      params.merge!(email: current_user.email)
      subscription = BillingManager::Subscription.new(user_id: current_user.id)
      subscription.state_machine.transition_to!(:saved_card)
    end

  end
end
