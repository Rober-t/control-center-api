require './lib/service'
require './app/models/organisation_manager/user'
require './app/mailers/invitation_email_sender'

module OrganisationManagerServices
  class ResendInvitationService < Service

    def execute
      @user = scoped_users.find_by(email: params[:email])
      return false unless @user.registration_token
      Mailers::InvitationEmailSender.new.perform(@user.id)
      true
    rescue NoMethodError
      raise ActiveRecord::RecordNotFound
    end

    private

    def scoped_users
      current_organisation.users
    end

  end
end
