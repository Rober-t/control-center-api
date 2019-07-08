# require 'stripe'
# require 'stripe_event'
# require './app/models/billing_manager/stripe_handlers/customer_updated'
# require './app/models/billing_manager/stripe_handlers/subscription_updated'
# require './app/models/billing_manager/stripe_handlers/subscription_deleted'

# StripeEvent.configure do |events|
#   events.subscribe 'customer.subscription.updated', BillingManager::StripeHandlers::SubscriptionUpdated.new
#   events.subscribe 'customer.subscription.deleted', BillingManager::StripeHandlers::SubscriptionDeleted.new
#   events.subscribe 'customer.updated', BillingManager::StripeHandlers::CustomerUpdated.new
# end

# Stripe.api_key = Figaro.env.stripe_api_key
