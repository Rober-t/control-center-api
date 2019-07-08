require './app/base'
require './lib/service_helpers'
require './lib/data_manager_helpers'
require './api/data_manager/nodes'
require './api/data_manager/dashboards'

module App
  class DataManager < Grape::API
    include App::Base

    helpers ServiceHelpers
    helpers DataManagerHelpers

    mount API::DataManager::Nodes
    mount API::DataManager::Dashboards
  end
end

