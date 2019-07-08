require './app/models/billing_manager/subscription'

class BillingManager
  class StripeHandlers
    class CustomerUpdated

      def call(event)
        subscription = Subscription.find_by(customer_id: event.data.object.id)
        subscription.transition_to!(:updated_customer_via_webhook, {
          default_card: event.data.object.default_source
        })
      end

    end
  end
end
