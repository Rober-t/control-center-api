require './lib/service'
require './app/models/data_manager/node'

module DataManagerServices
  class CreateNodeService < Service

    def execute
      node_attrs = params.merge!(organisation_id: current_organisation.id)
      node = DataManager::Node.create!(node_attrs.to_h)
      node
    end

  end
end
