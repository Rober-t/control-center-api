require 'spec_helper'

describe "Organisations" do

  before(:each) do
    set_auth_header current_user
  end

  describe "POST organisations", autodoc: true do
    it "creates organisation" do
      post "organisations", { data: { name: 'test7', admin: { email: 'test7@testing.com' } } }

      expect(last_response.status).to eq 201
      expect(last_response.header).to be_valid_json
      expect(JSON.parse(last_response.body)["data"]["organisation"].present?).to eq true
      expect(JSON.parse(last_response.body)["data"]["admin"].present?).to eq true
    end
  end

  describe 'PUT organisations/:id', autodoc: true do
    it 'updates organisation' do
      params = { data: { name: "new_org_name" } }

      put "organisations/#{current_organisation.id}", params

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("organisation")
      expect(current_organisation.reload.name).to eq "new_org_name"
    end
  end

  describe 'Delete organisations/:id', autodoc: true do
    it 'deletes organisation' do
      delete "organisations/#{current_organisation.id}"

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("success")
    end
  end

end

