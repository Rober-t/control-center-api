require './app/models/billing_manager/subscription'

class BillingManager
  class StripeHandlers
    class SubscriptionDeleted

      def call(event)
        subscription = Subscription.find_by(subscription_id: event.data.object.id)
        subscription.transition_to!(:deleted_subscription_via_webhook, {
          payload: event.data.object
        })
      end

    end
  end
end
