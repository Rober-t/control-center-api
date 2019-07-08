require 'spec_helper'
require './app/models/organisation_manager/organisation'
require './app/models/organisation_manager/membership'
require './app/models/organisation_manager/user'

describe "Users" do

  before(:each) do
    set_auth_header current_user
  end

  describe "GET users", autodoc: true do
    it "retrieves a list of users" do
      get "users"

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("users")
    end
  end

  describe "GET users/:id", autodoc: true do
    it "retrieves user" do
      get "users/#{current_user.id}"

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("user")
    end
  end

  describe "POST users", autodoc: true do
    it "creates user" do
      post "users", { data: { email: 'invite@test.com' } }

      expect(last_response.status).to eq 201
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("user")
    end
  end

  describe "PUT users/:id", autodoc: true do
    it 'updates user' do
      put "users/#{current_user.id}", { data: { name: "new test name" } }

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("user")
      expect(current_user.reload.name).to eq "new test name"
    end
  end

  describe "DELETE users/:id", autodoc: true do
    it 'deletes user' do
      delete "users/#{@current_user.id}"

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("success")
    end
  end

end
