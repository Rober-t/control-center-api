require './app/base'
require './lib/service_helpers'
require './lib/support_manager_helpers'
require './api/support_manager/tickets'
require './api/support_manager/comments'

module App
  class SupportManager < Grape::API
    include App::Base

    helpers ServiceHelpers
    helpers SupportManagerHelpers

    mount API::SupportManager::Tickets
    mount API::SupportManager::Comments
  end
end
