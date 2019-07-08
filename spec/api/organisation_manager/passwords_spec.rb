require 'spec_helper'

describe "Passwords" do

  describe 'POST passwords/reset', autodoc: true do
    it 'sends reset password email' do
      params = { data: { email: current_user.email } }

      post 'passwords/actions/reset', params

      expect(last_response.status).to eq 201
      expect(last_response.header).to be_valid_json
    end
  end

  describe 'POST passwords', autodoc: true do
    it 'resets password' do
      current_user.update!(reset_password_token: current_user.generate_token)

      post "passwords", params = { 
        data: {
          password: "new_password",
          token: current_user.reset_password_token
        }}

      expect(last_response.status).to eq 201
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("success")
    end
  end
end
