require './lib/service'
require './app/models/organisation_manager/organisation'
require './app/models/organisation_manager/user'

module AuthManagerServices
  class RevokeTokenService < Service

    def execute
      user = current_organisation.users.find(params[:id])
      user.update!(jti: nil)
    end

  end
end



