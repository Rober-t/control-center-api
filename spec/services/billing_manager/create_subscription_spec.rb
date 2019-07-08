require 'spec_helper'
require './services/billing_manager_services/create_subscription'
require './app/models/billing_manager/subscription'
require './app/models/organisation_manager/user'

describe BillingManagerServices::CreateSubscriptionService do

  it "creates a new subscription" do
    params = {
      card_token: stripe_helper.generate_card_token,
      plan: "pro"
    }

    service = BillingManagerServices::CreateSubscriptionService.new(
      params,
      current_organisation,
      current_user
    )

    expect { service.run }.to change(BillingManager::Subscription, :count).by(1)
    expect(current_user.subscription.plan).to eq "pro"
  end
  
end
