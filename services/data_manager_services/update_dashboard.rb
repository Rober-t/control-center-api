require './lib/service'
require './app/models/data_manager/dashboard'

module DataManagerServices
  class UpdateDashboardService < Service

    def execute
      dashboard = scoped_dashboards.find(params[:id])
      dashboard.update!(params.to_h)
      dashboard
    end

    private

    def scoped_dashboards
  		DataManager::Dashboard.where(organisation_id: current_organisation.id)
  	end

  end
end
