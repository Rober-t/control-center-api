require './lib/service'
require './app/models/organisation_manager/user'
require './app/models/organisation_manager/organisation'
require './app/models/organisation_manager/membership'
require './app/models/billing_manager/subscription'
require './app/mailers/transfer_ownership_email_sender'

module OrganisationManagerServices
  class RequestOwnershipTransferService < Service

    def execute
      @transferor = scoped_users.find(current_user.id)
      @transferee = scoped_users.find_by(email: params[:email])

      if @transferor.subscription.present?
        unless transferee_has_card?
          raise CardError.new("Card not found - #{@transferee.email}")
        end
      end

      update_transfer_attributes!
      send_transfer_ownership_email!
      @transferee.membership
    rescue NoMethodError
      raise ActiveRecord::RecordNotFound
    end

    private

    def scoped_users
      current_organisation.users
    end

    def transferee_has_card?
      @transferee.subscription && @transferee.subscription.default_card
    end

    def update_transfer_attributes!
      membership = @transferee.membership
      membership.transfer_token = @transferee.generate_token
      membership.transferor_id = @transferor.id
      membership.save!
    end

    def send_transfer_ownership_email!
      Mailers::TransferOwnershipEmailSender.new.perform(@transferee.id)
    end

  end
end
