require './app/base'
require './lib/service_helpers'
require './api/organisation_manager/organisations'
require './api/organisation_manager/memberships'
require './api/organisation_manager/users'
require './api/organisation_manager/confirmations'
require './api/organisation_manager/passwords'

module App
  class OrganisationManager < Grape::API
    include App::Base

    helpers ServiceHelpers

    mount API::OrganisationManager::Organisations
    mount API::OrganisationManager::Memberships
    mount API::OrganisationManager::Users
    mount API::OrganisationManager::Confirmations
    mount API::OrganisationManager::Passwords
  end
end

