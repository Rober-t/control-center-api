require 'spec_helper'
require './app/models/organisation_manager/membership'
require './services/organisation_manager_services/request_ownership_transfer'
require './services/billing_manager_services/create_subscription'

describe OrganisationManagerServices::RequestOwnershipTransferService do

  before do
    @transferor = current_user
    @transferee = OrganisationManager::User.create!(
      email: "test2@testing.com",
      invited_by_id: current_user.id,
      organisation: current_user.organisation
    )
  end

  it "generates transfer token" do
    setup_stripe_subscription(@transferee)

    params = { email: @transferee.email }

    service = OrganisationManagerServices::RequestOwnershipTransferService.new(
      params,
      current_organisation,
      current_user
    )

    subject = service.run

    expect(subject).to be_instance_of OrganisationManager::Membership
    expect(@transferee.membership.reload.transfer_token).not_to be nil
  end

  context "when transferee does not have a card saved" do
    it "raises an error" do
      setup_stripe_subscription(@transferor)

      params = { email: @transferee.email }

      service = OrganisationManagerServices::RequestOwnershipTransferService.new(
        params,
        current_organisation,
        current_user
      )

      expect{ service.run }.to raise_error(CardError)
    end
  end
  
end
