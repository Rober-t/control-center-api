require './app/models/data_manager/node'
require './app/models/data_manager/dashboard'

module DataManagerHelpers

	def scoped_dashboards
  	DataManager::Dashboard.where(organisation_id: current_organisation.id)
  end

  def scoped_nodes
   	DataManager::Node.where(organisation_id: current_organisation.id)
  end

end
