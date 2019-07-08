require 'spec_helper'
require './services/organisation_manager_services/invite_user'
require './app/mailers/invitation_email_sender'
require 'timecop'

describe OrganisationManagerServices::InviteUserService do

  context "when invitee does not already exist" do
    before do
      Timecop.freeze(Time.local(1690))
    end

    it "creates a new user" do
      expect { service.run }.to change(OrganisationManager::User, :count).by(2)
    end

    it "creates a new user with the correct credentials" do
      subject = service.run

      expect(subject).to be_instance_of OrganisationManager::User
      expect(subject.email).to eq "invitee@test.com"
      expect(subject.registration_token).not_to eq nil
      expect(subject.invited_by_id).to eq current_user.id
    end

    it "adds the new user to the correct organisation" do
      subject = service.run

      expect(subject.organisation).to eq current_user.organisation
    end

    it "increments the invitations sent counter" do
      expect(current_user.invitations_sent).to eq 0

      service.run

      expect(current_user.reload.invitations_sent).to eq 1
    end

    before do
      Timecop.freeze(Time.local(1690))
    end
  end

  context "when invitee does already exist" do
    it "raises error message" do
      subject = service(current_user.email)
      expect { subject.run }.to raise_error(ActiveRecord::RecordInvalid)
        .with_message("Validation failed: Email has already been taken")
    end
  end

  after do
    Timecop.return
  end

  private

  def service(email = 'invitee@test.com')
    params = { email: email }
    OrganisationManagerServices::InviteUserService.new(params, current_organisation, current_user)
  end

end
