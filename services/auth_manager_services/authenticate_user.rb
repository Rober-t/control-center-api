require './lib/service'
require './app/models/organisation_manager/user'

module AuthManagerServices
  class AuthenticateUserService < Service

    def execute
      user = OrganisationManager::User.find_by_email(params.fetch(:email, nil))
      
      raise Errors::Unauthorized if user.nil? || user.confirmed_at.nil?

      if user.authenticate(params.fetch(:password, nil))
        {
          "access_token": "#{user.generate_token}",
          "token_type": "Bearer",
          "expires_in":  31536000
        }
      else
        raise Errors::Unauthorized
      end
    end

  end
end
