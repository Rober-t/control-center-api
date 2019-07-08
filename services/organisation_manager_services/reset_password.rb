require './lib/service'
require './app/models/organisation_manager/user'

module OrganisationManagerServices
  class ResetPasswordService < Service

    def execute
      token = params[:token].strip
      JWT.decode(token, Figaro.env.jwt_secret, true, algorithm: 'HS256')
      user = OrganisationManager::User.find_by(reset_password_token: token)
      user.password = params[:password]
      user.reset_password_token = nil
      user.jti = nil
      user.save!
    rescue NoMethodError
      raise ActiveRecord::RecordNotFound
    end

  end
end
