require './lib/service'
require './app/models/organisation_manager/user'
require './app/mailers/reset_password_email_sender'

module OrganisationManagerServices
  class SendResetPasswordEmailService < Service

    def execute
      user = OrganisationManager::User.find_by(email: params[:email])
      user.reset_password_token = user.generate_token
      user.save!
      Mailers::ResetPasswordEmailSender.new.perform(user.id)
      true
    rescue NoMethodError
      raise ActiveRecord::RecordNotFound
    end

  end
end

