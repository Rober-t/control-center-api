require 'spec_helper'
require './services/auth_manager_services/revoke_token'

describe AuthManagerServices::RevokeTokenService do

  before do
    current_user.update(
      confirmed_at: Time.now.utc,
      password: "Testing1234"
    )

    params = {
      email: current_user.email,
      password: current_user.password
    }

    service = AuthManagerServices::AuthenticateUserService.new(
      params,
      current_organisation,
      current_user
    ).run
  end 

  context "with correct params" do
    it 'revokes token' do
      expect(current_user.jti).not_to be nil
      
      params = {
        id: current_user.id
      }

      service = AuthManagerServices::RevokeTokenService.new(
        params,
        current_organisation,
        current_user
      )

      response = service.run
      expect(response).to eq true
      expect(current_user.reload.jti).to be nil
    end
  end

end

