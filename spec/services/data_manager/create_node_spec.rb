require 'spec_helper'
require './app/models/data_manager/node'
require './services/data_manager_services/create_node'

describe DataManagerServices::CreateNodeService do

  context "with correct params" do
    it 'creates node' do
      params = {
        name: "Test",
        url: "http://localhost:8080"
      }

      service = DataManagerServices::CreateNodeService.new(
        params,
        current_organisation,
        current_user
      )

      subject = service.run
      expect(subject).to be_instance_of DataManager::Node
      expect(subject.name).to eq "Test"
      expect(subject.url).to eq  "http://localhost:8080"
    end
  end

end

