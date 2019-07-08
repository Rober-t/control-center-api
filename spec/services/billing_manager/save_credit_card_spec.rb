require 'spec_helper'
require './services/billing_manager_services/save_credit_card'
require './app/models/billing_manager/subscription'

describe BillingManagerServices::SaveCreditCardService do

  it "saves card" do
    card_token = stripe_helper.generate_card_token

    params = { card_token: card_token }

    service = BillingManagerServices::SaveCreditCardService.new(
      params,
      current_organisation,
      current_user
    )

    expect{ service.run }.to change(BillingManager::Subscription, :count).by(1)
    expect(current_user.subscription.default_card).not_to be nil
  end

end
