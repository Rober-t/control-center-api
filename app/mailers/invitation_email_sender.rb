require './app/models/organisation_manager/user'
require './app/mailers/mailer'

class Mailers
  class InvitationEmailSender

    def perform(id)
      user = find_user(id)
      Mailer.new.send_invitation_mail(user, binding)
    end

    def find_user(id)
      OrganisationManager::User.find_by(id: id)
    end

  end
end
