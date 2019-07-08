require 'spec_helper'
require './services/organisation_manager_services/update_user'

describe OrganisationManagerServices::UpdateUserService do

  context "with correct params" do
    it "updates organisation" do
      expect(current_user.email).not_to eq "new_email@test.com"

      params = {
        id: current_user.id,
        email: "new_email@test.com"
      }

      service = OrganisationManagerServices::UpdateUserService.new(
        params,
        current_organisation,
        current_user
      )

      subject = service.run
      expect(subject).to be_instance_of OrganisationManager::User
      expect(subject.reload.email).to eq "new_email@test.com"
    end
  end

end

