require 'spec_helper'
require './services/billing_manager_services/create_subscription'
require './services/billing_manager_services/update_subscription'

describe BillingManagerServices::UpdateSubscriptionService do

  before do
    setup_stripe_subscription(current_user)
  end

  it "updates subscription" do
    expect(current_user.subscription.plan).to eq "pro"

    params = {
      plan: "enterprise"
    }

    service = BillingManagerServices::UpdateSubscriptionService.new(
      params,
      current_organisation,
      current_user
    ).run

    expect(current_user.subscription.reload.plan).to eq "enterprise"
  end
  
end
