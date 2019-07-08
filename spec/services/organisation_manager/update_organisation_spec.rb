require 'spec_helper'
require './services/organisation_manager_services/update_organisation'

describe OrganisationManagerServices::UpdateOrganisationService do

  context "with correct params" do
    it "updates organisation" do
      expect(current_organisation.name).not_to eq "new_org_name"

      params = {
        name: "new_org_name"
      }

      service = OrganisationManagerServices::UpdateOrganisationService.new(
        params,
        current_organisation,
        current_user
      )

      subject = service.run
      expect(subject).to be_instance_of OrganisationManager::Organisation
      expect(subject.name).to eq "new_org_name"
    end
  end

end

