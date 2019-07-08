require './lib/service'
require './app/models/organisation_manager/user'

module OrganisationManagerServices
  class ConfirmUserService < Service

    def execute
      token = params[:token].strip
      JWT.decode(token, Figaro.env.jwt_secret, true, algorithm: 'HS256')
      user = OrganisationManager::User.find_by(registration_token: token)
      user.update!(
        password: params[:password],
        name: params[:name],
        registration_token: nil,
        confirmed_at: Time.now.utc
      )
      user
    end

  end
end


      