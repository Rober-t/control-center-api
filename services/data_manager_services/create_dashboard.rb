require './lib/service'
require './app/models/data_manager/dashboard'

module DataManagerServices
  class CreateDashboardService < Service

    def execute
      dashboard_attrs = params.merge!(organisation_id: current_organisation.id)
      dashboard = DataManager::Dashboard.create!(dashboard_attrs.to_h)
      dashboard
    end

  end
end
