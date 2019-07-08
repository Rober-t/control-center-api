require 'grape'
require 'stripe_event'

module API
  module BillingManager
    class Stripe < Grape::API
      resource :stripe do

        desc 'Create Stripe billing event'
        post '/billing_events' do
          data = JSON.parse(params.to_json, symbolize_names: true)
          StripeEvent.instrument(data)
          { success: true }
        end

      end
    end
  end
end
