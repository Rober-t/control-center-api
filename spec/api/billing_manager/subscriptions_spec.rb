require 'spec_helper'
require './app/models/organisation_manager/membership'
require './services/billing_manager_services/create_subscription'
require './services/billing_manager_services/save_credit_card'
require './services/organisation_manager_services/create_account'

describe "Subscriptions" do

  before(:each) do
    set_auth_header current_user
  end

  describe "GET subscription", autodoc: true do
    it "retrieves subscription" do
      setup_subscription
      subscription = current_user.subscription
      subscription.update!(state: 'active')

      get "subscriptions"

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("subscription")
    end
  end

  describe "POST subscriptions", autodoc: true do
    it "creates subscription" do
      params = {
        data: {
          card_token: stripe_helper.generate_card_token,
          plan: 'pro'
        }
      }

      post "subscriptions", params

      expect(last_response.status).to eq 201
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("subscription")
    end
  end

  describe "PUT subscriptions/:id", autodoc: true do
    it "updates subscription" do
      setup_subscription
      subscription = current_user.subscription
      subscription.update!(state: 'active')

      params = { data: { plan: 'enterprise' } }
      put "subscriptions/#{subscription.id}", params

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("subscription")
    end
  end

  describe "DELETE subscriptions/:id", autodoc: true do
    it "cancels subscription" do
      setup_subscription
      subscription = current_user.subscription
      subscription.update!(state: 'active')

      delete "subscriptions/#{subscription.id}"

      expect(last_response.status).to eq 200
      expect(subscription.reload.cancel_at_period_end).to eq true
    end
  end

  describe "actions" do
    before(:each) do
      setup_subscription
      current_user.subscription.update!(state: 'active')
    end

    describe "POST subscriptions/:id/actions/update_credit_card_owner", autodoc: true do
      it "updates customer's email" do
        subscription = current_user.subscription

        params = { data: { email: 'new_test_email@test.io' } }
        post "subscriptions/#{subscription.id}/actions/update_credit_card_owner", params

        expect(last_response.status).to eq 201
      end
    end

    describe "POST subscriptions/:id/actions/update_credit_card", autodoc: true do
      it "updates card" do
        subscription = current_user.subscription

        params = { data: { card_attributes: { exp_year: 2050 } } }
        post "subscriptions/#{subscription.id}/actions/update_credit_card", params

        expect(last_response.status).to eq 201
      end
    end

  end

  private

  def setup_subscription
    params = {
      card_token: stripe_helper.generate_card_token,
      plan: 'pro'
    }

    BillingManagerServices::CreateSubscriptionService.new(
      params,
      current_organisation,
      current_user
    ).run
  end

end
