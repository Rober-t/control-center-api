require 'spec_helper'
require './services/organisation_manager_services/delete_organisation'
require './services/billing_manager_services/create_subscription'
require './app/models/organisation_manager/organisation'
require './app/models/organisation_manager/membership'
require './app/models/organisation_manager/user'
require './app/models/auth_manager/access'

describe OrganisationManagerServices::DeleteOrganisationService do
  
  context "when user has subscription and is owner of organisation" do
    before do
      setup_stripe_subscription(current_user)
    end

    it "deletes user and organisation" do
      current_user.membership.update!(role: "owner")

      params = {
        id: current_user.id
      }

      service = OrganisationManagerServices::DeleteOrganisationService.new(
        params,
        current_organisation,
        current_user
      )

      subject = service.run
      expect(subject).to be_instance_of OrganisationManager::User
      expect(subject.destroyed?).to eq true
      expect(subject.subscription.destroyed?).to eq true
      expect(subject.organisation.destroyed?).to eq true
    end
  end

  context "when user is not owner of organisation" do
    it "does not delete user or organisation" do
      current_user.membership.update!(role: 'member')

      params = {
        id: current_user.id
      }

      service = OrganisationManagerServices::DeleteOrganisationService.new(
        params,
        current_organisation,
        current_user
      )

      expect{service.run}.to raise_error(Errors::Forbidden)
      expect(current_user.destroyed?).to eq false
      expect(current_user.organisation.destroyed?).to eq false
    end
  end

end
