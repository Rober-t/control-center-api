require './lib/service'
require './app/models/billing_manager/subscription'

module BillingManagerServices
  class UpdateCreditCardOwnerService < Service

    def execute
      subscription = current_user.subscription
      subscription.transition_to!(:updated_customer_email, params.to_h)
    end

  end
end

