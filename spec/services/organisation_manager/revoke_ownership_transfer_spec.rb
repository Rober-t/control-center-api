require 'spec_helper'
require './app/models/organisation_manager/membership'
require './services/organisation_manager_services/revoke_ownership_transfer'
require './services/billing_manager_services/create_subscription'

describe OrganisationManagerServices::RevokeOwnershipTransferService do

  before do
    @transferor = current_user
    @transferee = OrganisationManager::User.create!(
      email: "test2@testing.com",
      invited_by_id: current_user.id,
      organisation: current_user.organisation
    )
  end

  it "revokes transfer token" do
    setup_stripe_subscription(@transferee)

    params = { email: @transferee.email }

    service = OrganisationManagerServices::RevokeOwnershipTransferService.new(
      params,
      current_organisation,
      current_user
    )

    result = service.run

    expect(result).to eq true
    expect(@transferee.membership.reload.transfer_token).to be nil
  end
  
end
