require 'spec_helper'
require './services/organisation_manager_services/accept_ownership_transfer'
require './services/organisation_manager_services/request_ownership_transfer'
require './services/billing_manager_services/save_credit_card'

describe OrganisationManagerServices::AcceptOwnershipTransferService do

  before do
    @transferor = current_user
    @transferee = OrganisationManager::User.create!(
      email: "test2@testing.com",
      invited_by_id: current_user.id,
      organisation: current_user.organisation
    )
    allow_any_instance_of(StripeMock::Instance).to receive(:get_card_by_token) {
      StripeMock::Data.mock_card Stripe::Util.symbolize_names({})
    }
  end

  context "when subscription is present" do
    before do
      setup_stripe_subscription(@transferee)
      setup_stripe_subscription(@transferor)

      OrganisationManagerServices::RequestOwnershipTransferService.new(
        { email: @transferee.email },
        current_organisation,
        current_user
      ).run

      OrganisationManagerServices::AcceptOwnershipTransferService.new(
        { transfer_token: @transferee.membership.reload.transfer_token },
        current_organisation,
        current_user
      ).run
    end

    it "transfers subscription" do
      expect(@transferee.subscription.reload.plan).to eq @transferee.plan
      expect(@transferor.subscription.reload.state).to eq "canceled"
    end

    it "transfers ownership" do
      expect(@transferee.membership.reload.role).to eq "owner"
      expect(@transferor.membership.reload.role).to eq "member"
    end

    it "deletes transfer token" do
      expect(@transferee.membership.reload.transfer_token).to be nil
    end
  end

  context "when no subscription is present" do
    before do
      OrganisationManagerServices::RequestOwnershipTransferService.new(
        { email: @transferee.email },
        current_organisation,
        current_user
      ).run

      service = OrganisationManagerServices::AcceptOwnershipTransferService.new(
        { transfer_token: @transferee.membership.reload.transfer_token },
        current_organisation,
        current_user
      ).run
    end

    it "transfers ownership" do
      expect(@transferee.membership.reload.role).to eq "owner"
      expect(@transferor.membership.reload.role).to eq "member"
    end

    it "deletes transfer token" do
      expect(@transferee.membership.reload.transfer_token).to be nil
    end
  end
  
end
