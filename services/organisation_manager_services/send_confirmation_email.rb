require './lib/service'
require './app/models/organisation_manager/user'
require './app/mailers/confirmation_email_sender'

module OrganisationManagerServices
  class SendConfirmationEmailService < Service

    def execute
      user = find_user
      user.registration_token = user.generate_token
      user.save!
      Mailers::ConfirmationEmailSender.new.perform(user.id)
      true
    rescue NoMethodError
      raise ActiveRecord::RecordNotFound
    end

    private

    def find_user
      OrganisationManager::User.find_by(email: params[:email])
    end

  end
end

