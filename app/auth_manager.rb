require './app/base'
require './lib/service_helpers'
require './api/auth_manager/authentications'

module App
  class AuthManager < Grape::API
    include App::Base

    helpers ServiceHelpers

    mount API::AuthManager::Authentications
  end
end

