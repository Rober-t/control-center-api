require './lib/service'
require './app/models/organisation_manager/organisation'
require './app/models/organisation_manager/user'

module OrganisationManagerServices
  class UpdateMembershipService < Service

    def execute
      membership = current_organisation.memberships.find(params[:id])
      membership.update!(role: params[:role])
      membership
    end

  end
end
