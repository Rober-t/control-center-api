require 'spec_helper'
require './app/models/data_manager/node'
require './app/models/organisation_manager/user'

describe "Nodes" do

  before(:each) do
    set_auth_header current_user
    @node_west = DataManager::Node.create!(name: 'node_west', url: "http://www.my-server-1.com", organisation_id: current_organisation.id)
    @node_east = DataManager::Node.create!(name: 'node_east', url: "http://www.my-server-2.com", organisation_id: current_organisation.id)
    @node_south = DataManager::Node.create!(name: 'node_south', url: "http://www.my-server-3.com", organisation_id: current_organisation.id)
    @node_north = DataManager::Node.create!(name: 'node_north', url: "http://www.my-server-4.com", organisation_id: current_organisation.id)
  end

  describe "GET nodes", autodoc: true do
    it "retrieves an organisation's nodes" do
      get "nodes"

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("nodes")
    end
  end

    describe "GET nodes/:id", autodoc: true do
    it "retrieves node" do
      get "nodes/#{@node_west.id}"

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("node")
    end
  end

  describe "POST nodes", autodoc: true do
    it "creates node" do
      params = {
        data: {
          name: 'node_other',
          url: "http://www.my-server.com"
        }
      }

      post "nodes", params
      
      expect(last_response.status).to eq 201
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("node")
    end
  end

  describe 'PUT nodes/:id', autodoc: true do
    it 'updates organisation node' do
      params = { data: { name: 'sales_node' } }

      put "nodes/#{@node_west.id}", params

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("node")
    end
  end

  describe "DELETE nodes/:id", autodoc: true do
    it 'deletes node' do
      delete "nodes/#{@node_west.id}"

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("success")
    end
  end

  # describe "POST nodes/:id/users", autodoc: true do
  #   before do
  #     @user = OrganisationManager::User.create!(
  #       email: 'test5@testing.com',
  #       organisation: current_user.organisation
  #     )
  #   end

  #   it "adds user to node" do
  #     params = { data: { user_id: @user.id } }
  #     post "nodes/#{@node_west.id}/users", params

  #     expect(last_response.status).to eq 201
  #     expect(last_response.header).to be_valid_json
  #   end
  # end

  # describe "DELETE nodes/:id/users/:id", autodoc: true do
  #   before do
  #     @user = OrganisationManager::User.create!(
  #       email: 'test5@testing.com',
  #       organisation: current_user.organisation
  #     )
  #     @node_west.users << @user
  #   end

  #   it "deletes user from node" do
  #     expect(@node_west.users.find_by(id: @user.id)).not_to be nil

  #     delete "nodes/#{@node_west.id}/users/#{@user.id}"

  #     expect(last_response.status).to eq 204
  #     expect(@node_west.users.find_by(id: @user.id)).to be nil
  #   end
  # end

end

