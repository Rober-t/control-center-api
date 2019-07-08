require './app/auth_manager'
require './app/organisation_manager'
require './app/support_manager'
require './app/billing_manager'
require './app/data_manager'
require './app/status'

require './services/organisation_manager_services/create_account'

module ApiHelpers
  def app
    Rack::Cascade.new([
      App::AuthManager,
      App::OrganisationManager,
      App::SupportManager,
      App::BillingManager,
      App::DataManager,
      App::Status
    ])
  end

  def set_auth_header(user)
    auth = "Bearer #{user.generate_token}"
    header 'Authorization', auth
  end

  def current_organisation
    @current_organisation ||= create_organistaion_service[:organisation]
  end

  def current_user
    @current_user ||= create_organistaion_service[:user]
  end

  def create_organistaion_service
    @service_response ||= OrganisationManagerServices::CreateAccountService.new(
      {
        admin: {
            email: 'test@testing.com'
        },
        name: 'Test'
      }).run
  end

  def generate_expired_token(user)
    JWT.encode(
      { exp: (Time.now.utc - 6.hours).to_i(), id: user.id.to_s }, Figaro.env.jwt_secret
    )
  end
end

