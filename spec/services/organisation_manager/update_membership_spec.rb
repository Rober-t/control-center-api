require 'spec_helper'
require './services/organisation_manager_services/update_membership'

describe OrganisationManagerServices::UpdateMembershipService do

  before do
    @membership = current_user.membership
  end

  context "with correct params" do
    it "updates membership" do
      expect(@membership.role).not_to eq "admin"

      params = {
        id: @membership.id,
        role: "admin",
      }

      service = OrganisationManagerServices::UpdateMembershipService.new(
        params,
        current_organisation,
        current_user
      )

      subject = service.run
      expect(subject).to be_instance_of OrganisationManager::Membership
      expect(subject.role).to eq "admin"
    end
  end

  context "when an invalid membership role is passed" do
    it "does not update membership" do
      params = {
        id: @membership.id,
        role: "super_user",
      }

      service = OrganisationManagerServices::UpdateMembershipService.new(
        params,
        current_organisation,
        current_user
      )

      expect{ service.run }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

end

