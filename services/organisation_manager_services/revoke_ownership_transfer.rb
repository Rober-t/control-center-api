require './lib/service'
require './app/models/organisation_manager/organisation'
require './app/models/organisation_manager/user'

module OrganisationManagerServices
  class RevokeOwnershipTransferService < Service

    def execute
      scoped_users = current_organisation.users
      user = scoped_users.find_by(email: params[:email])
      user.membership.update!(transfer_token: nil)
    end

  end
end
