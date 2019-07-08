require './lib/service'
require './app/models/organisation_manager/user'
require './app/mailers/invitation_email_sender'

module OrganisationManagerServices
  class InviteUserService < Service

    def execute
      @user = OrganisationManager::User.create!(email: params[:email])
      @user.registration_token = @user.generate_token
      @user.invited_by_id = current_user.id
      @user.organisation = current_organisation
      @user.save!
      send_invitation_mail!
      increment_invitations_sent!
      @user
    end

    private

    def send_invitation_mail!
      Mailers::InvitationEmailSender.new.perform(@user.id)
    end

    def increment_invitations_sent!
      OrganisationManager::User.increment_counter(:invitations_sent, current_user.id)
    end

  end
end


