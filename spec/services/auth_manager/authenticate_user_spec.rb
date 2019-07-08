require 'spec_helper'
require './services/auth_manager_services/authenticate_user'

describe AuthManagerServices::AuthenticateUserService do

  before do
    current_user.update(
      confirmed_at: Time.now.utc,
      password: "Testing1234"
    )
  end 

  context "with correct params" do
    it 'authenticates user' do
      params = {
        email: current_user.email,
        password: current_user.password
      }

      service = AuthManagerServices::AuthenticateUserService.new(
        params,
        current_organisation,
        current_user
      )

      response = service.run
      expect(response[:access_token]).not_to be nil
      expect(response[:expires_in]).not_to be nil
      expect(response[:token_type]).not_to be nil
    end
  end

end

