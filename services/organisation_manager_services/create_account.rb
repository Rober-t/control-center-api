require './lib/service'
require './app/models/organisation_manager/user'
require './app/models/organisation_manager/organisation'
require './app/models/auth_manager/access'
require './app/mailers/confirmation_email_sender'

module OrganisationManagerServices
  class CreateAccountService < Service

    def execute
      @user = create_user
      @organisation = create_organisation
      @user.organisation = @organisation
      @user.membership.update!(role: 'owner')
      create_access_for_user!
      update_confirmation_attributes!
      Mailers::ConfirmationEmailSender.new.perform(@user.id)
      { 
        organisation: @organisation, 
        user: @user 
      }
    end

    private

    def create_user
      OrganisationManager::User.create!(email: params[:admin][:email])
    end

    def create_organisation
      OrganisationManager::Organisation.create!(name: params[:name])
    end

    def create_access_for_user!
      AuthManager::Access.create!(user_id: @user.id, start_date: Time.now.utc)
    end

    def update_confirmation_attributes!
      @user.registration_token = @user.generate_token
      @user.save!
    end

  end
end
