require './lib/service'
require './app/models/data_manager/node'
require './lib/data_manager_helpers'

module DataManagerServices
  class UpdateNodeService < Service

    def execute
      node = scoped_nodes.find(params[:id])
      node.update!(params.to_h)
      node
    end

    private

    def scoped_nodes
    	DataManager::Node.where(organisation_id: current_organisation.id)
  	end

  end
end
