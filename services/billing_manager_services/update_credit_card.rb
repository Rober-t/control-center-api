require './lib/service'
require './app/models/billing_manager/subscription'

module BillingManagerServices
  class UpdateCreditCardService < Service

    def execute
      subscription = current_user.subscription
      subscription.transition_to!(:updated_card, params.to_h)
    end

  end
end
