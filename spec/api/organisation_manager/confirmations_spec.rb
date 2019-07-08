require 'spec_helper'

describe "Confirmations" do

  describe 'POST confirmations/resend', autodoc: true do
    before do
      set_auth_header current_user
    end

    it 're-sends confirmation' do
      params = { data: { email: current_user.email } }

      post 'confirmations/actions/resend', params

      expect(last_response.status).to eq 201
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("success")
    end

  end

  describe 'POST confirmations', autodoc: true do
    it 'confirms user' do
      current_user.update(registration_token: current_user.generate_token)

      params = { data: { token: current_user.generate_token, name: "Tester", password: "Testing1234" } }

      post 'confirmations', params

      expect(last_response.status).to eq 201
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("success")
    end
  end

end
