require 'spec_helper'
require './services/organisation_manager_services/confirm_user'
require 'timecop'

describe OrganisationManagerServices::ConfirmUserService do
  
  context "with valid registration_token" do
    before do
      Timecop.freeze(Time.local(1690))
    end

    it "confirms the users account" do
      expect(current_user.confirmed_at).to eq nil

      params = { 
        token: current_user.registration_token,
        password: "Testing1234",
        name: "Confirmed"
      }

      service = OrganisationManagerServices::ConfirmUserService.new(params)

      subject = service.run

      expect(subject.registration_token).to be nil
      expect(subject.confirmed_at).to eq Time.now.utc
      expect(subject.name).to eq "Confirmed"
    end

    after do
      Timecop.return
    end
  end

  context "when the registration_token has expired" do
    it "does not confirm the users account" do
      expect(current_user.confirmed_at).to eq nil

      params = { 
        token: generate_expired_token(current_user),
        password: "Testing1234",
        name: "Confirmed"
      }

      service = OrganisationManagerServices::ConfirmUserService.new(params)

      expect{ service.run }.to raise_error(JWT::ExpiredSignature)
    end
  end

end
