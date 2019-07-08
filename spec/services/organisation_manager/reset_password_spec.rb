require 'spec_helper'
require './services/organisation_manager_services/reset_password'

describe OrganisationManagerServices::ResetPasswordService do

  context "with valid reset token" do
    before do
      current_user.update(reset_password_token: current_user.generate_token, password: "Password1234")
    end

    it "resets users password" do
      old_password_digest = current_user.password_digest

      params = {
        password: "new_password",
        token: current_user.generate_token
      }

      service = OrganisationManagerServices::ResetPasswordService.new(
        params,
        current_organisation,
        current_user,
      )

      result = service.run
      subject = current_user.reload

      expect(result).to eq true
      expect(subject.password_digest).not_to eq old_password_digest
      expect(subject.reset_password_token).to be nil
    end
  end

  context "when the reset token has expired" do
    before do
      current_user.update(reset_password_token: generate_expired_token(current_user))
    end

    it "does not reset the users password" do
      expired_token = generate_expired_token(current_user)

      params = {
        password: "new_password",
        token: expired_token
      }

      service = OrganisationManagerServices::ResetPasswordService.new(
        params,
        current_organisation,
        current_user
      )

      expect{ service.run }.to raise_error(JWT::ExpiredSignature)
    end
  end

end
