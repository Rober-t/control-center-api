require './lib/service'
require './app/models/organisation_manager/organisation'
require './app/models/organisation_manager/user'

module OrganisationManagerServices
  class DeleteUserService < Service

    def execute
      scoped_users = current_organisation.users
      user = scoped_users.find(params[:id])
      user.destroy!
    end

  end
end

