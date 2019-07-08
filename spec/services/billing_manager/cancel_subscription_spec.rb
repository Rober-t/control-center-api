require 'spec_helper'
require './services/billing_manager_services/cancel_subscription'

describe BillingManagerServices::CancelSubscriptionService do

  before do
    setup_stripe_subscription(current_user)
  end

  it "cancels subscription" do
    expect(current_user.subscription.active?).to eq true
    expect(current_user.subscription.state).to eq "active"
    expect(current_user.subscription.cancel_at_period_end).to eq false

    params = {}

    service = BillingManagerServices::CancelSubscriptionService.new(
      params,
      current_organisation,
      current_user
    ).run

    expect(current_user.subscription.active?).to eq true
    expect(current_user.subscription.state).to eq "active"
    expect(current_user.subscription.cancel_at_period_end).to eq true
  end
  
end
