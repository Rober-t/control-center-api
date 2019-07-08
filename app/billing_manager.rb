require './app/base'
require './lib/service_helpers'
require './api/billing_manager/stripe'
require './api/billing_manager/subscriptions'

module App
  class BillingManager < Grape::API
    include App::Base

    helpers ServiceHelpers

    mount API::BillingManager::Stripe
    mount API::BillingManager::Subscriptions
  end
end

