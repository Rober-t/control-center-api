require './lib/service'
require './app/models/organisation_manager/organisation'
require './app/models/organisation_manager/user'

module OrganisationManagerServices
  class UpdateOrganisationService < Service

    def execute
      current_organisation.update!(name: params[:name])
      current_organisation
    end

  end
end
