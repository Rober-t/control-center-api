require 'spec_helper'
require './app/models/data_manager/dashboard'
require './app/models/organisation_manager/user'

describe "Dashboards" do

  before(:each) do
    set_auth_header current_user
    @dashboard_one = DataManager::Dashboard.create!(name: 'dashboard_one', tree: "{\"direction\":\"row\",\"first\":{\"first\":\"http://localhost:8080/sse/path/to/my/data/5\",\"second\":\"http://localhost:8080/sse/path/to/my/data/4\",\"direction\":\"row\",\"splitPercentage\":30},\"second\":{\"direction\":\"column\",\"first\":\"http://localhost:8080/sse/path/to/my/data/3\",\"second\":\"http://localhost:8080/sse/path/to/my/data/2\"},\"splitPercentage\":70}", organisation_id: current_organisation.id)
    @dashboard_two = DataManager::Dashboard.create!(name: 'dashboard_two', tree: "{\"direction\":\"row\",\"first\":{\"first\":\"http://localhost:8080/sse/path/to/my/data/5\",\"second\":\"http://localhost:8080/sse/path/to/my/data/4\",\"direction\":\"row\",\"splitPercentage\":30},\"second\":{\"direction\":\"column\",\"first\":\"http://localhost:8080/sse/path/to/my/data/3\",\"second\":\"http://localhost:8080/sse/path/to/my/data/2\"},\"splitPercentage\":70}", organisation_id: current_organisation.id)
  end

  describe "GET dashboards", autodoc: true do
    it "retrieves an organisation's dashboards" do
      get "dashboards"

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("dashboards")
    end
  end

  describe "GET dashboards/:id", autodoc: true do
    it "retrieves dashboard" do
      get "dashboards/#{@dashboard_one.id}"

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("dashboard")
    end
  end

  describe "POST dashboards", autodoc: true do
    it "creates dashoard" do
      params = {
        data: {
          name: 'dashoard_other',
          tree:  "{\"direction\":\"row\",\"first\":{\"first\":\"http://localhost:8080/sse/path/to/my/data/5\",\"second\":\"http://localhost:8080/sse/path/to/my/data/4\",\"direction\":\"row\",\"splitPercentage\":30},\"second\":{\"direction\":\"column\",\"first\":\"http://localhost:8080/sse/path/to/my/data/3\",\"second\":\"http://localhost:8080/sse/path/to/my/data/2\"},\"splitPercentage\":70}"
        }
      }

      post "dashboards", params
      
      expect(last_response.status).to eq 201
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("dashboard")
    end
  end

  describe 'PUT dashboards/:id', autodoc: true do
    it 'updates organisation dashoard' do
      params = { data: { name: 'sales_dashoard' } }

      put "dashboards/#{@dashboard_one.id}", params

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("dashboard")
    end
  end

  describe "DELETE dashboards/:id", autodoc: true do
    it 'deletes dashoard' do
      delete "dashboards/#{@dashboard_one.id}"

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("success")
    end
  end

end