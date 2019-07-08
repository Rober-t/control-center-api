require './app/models/organisation_manager/user'
require './app/mailers/mailer'

class Mailers
  class TransferOwnershipEmailSender

    def perform(id)
      user = find_user(id)
      Mailer.new.send_transfer_ownership_mail(user, binding)
    end

    def find_user(id)
      OrganisationManager::User.find_by(id: id)
    end

  end
end
