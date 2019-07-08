require 'spec_helper'
require './app/models/data_manager/dashboard'
require './services/data_manager_services/create_dashboard'
require './services/data_manager_services/update_dashboard'

describe DataManagerServices::UpdateDashboardService do

  before do
    params = {
      name: "Test",
      tree:  "{\"direction\":\"row\",\"first\":{\"first\":\"http://localhost:8080/sse/path/to/my/data/5\",\"second\":\"http://localhost:8080/sse/path/to/my/data/4\",\"direction\":\"row\",\"splitPercentage\":30},\"second\":{\"direction\":\"column\",\"first\":\"http://localhost:8080/sse/path/to/my/data/3\",\"second\":\"http://localhost:8080/sse/path/to/my/data/2\"},\"splitPercentage\":70}"
    }

    @dashboard = DataManagerServices::CreateDashboardService.new(
      params,
      current_organisation,
      current_user
    ).run
  end

  context "with correct params" do
    it 'updates dashboard' do
      params = {
        id: @dashboard.id,
        name: "Test UPDATE",
        tree: "{\"direction\":\"row\",\"first\":{\"first\":\"http://localhost:8080/sse/path/to/my/data/6\",\"second\":\"http://localhost:8080/sse/path/to/my/data/2\",\"direction\":\"row\",\"splitPercentage\":50},\"second\":{\"direction\":\"column\",\"first\":\"http://localhost:8080/sse/path/to/my/data/3\",\"second\":\"http://localhost:8080/sse/path/to/my/data/2\"},\"splitPercentage\":50}"
      }

      service = DataManagerServices::UpdateDashboardService.new(
        params, 
        current_organisation, 
        current_user
      )

      subject = service.run
      expect(subject).to be_instance_of DataManager::Dashboard
      expect(subject.name).to eq "Test UPDATE"
      expect(subject.tree).to eq "{\"direction\":\"row\",\"first\":{\"first\":\"http://localhost:8080/sse/path/to/my/data/6\",\"second\":\"http://localhost:8080/sse/path/to/my/data/2\",\"direction\":\"row\",\"splitPercentage\":50},\"second\":{\"direction\":\"column\",\"first\":\"http://localhost:8080/sse/path/to/my/data/3\",\"second\":\"http://localhost:8080/sse/path/to/my/data/2\"},\"splitPercentage\":50}"
    end
  end
  
end