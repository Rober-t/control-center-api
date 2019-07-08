require 'spec_helper'
require './app/models/data_manager/node'
require './services/data_manager_services/create_node'
require './services/data_manager_services/update_node'

describe DataManagerServices::UpdateNodeService do

  before do
    params = {
      name: "Test",
      url: "http://localhost:8080"
    }

    @node = DataManagerServices::CreateNodeService.new(
      params,
      current_organisation,
      current_user
    ).run
  end

  context "with correct params" do
    it 'updates node' do
      params = {
        id: @node.id,
        name: "Test UPDATE",
        url: "http://localhost:3000"
      }

      service = DataManagerServices::UpdateNodeService.new(
        params, 
        current_organisation, 
        current_user
      )

      subject = service.run
      expect(subject).to be_instance_of DataManager::Node
      expect(subject.name).to eq "Test UPDATE"
      expect(subject.url).to eq "http://localhost:3000"
    end
  end
  
end