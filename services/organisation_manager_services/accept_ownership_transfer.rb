require './lib/service'
require './app/models/organisation_manager/user'
require './app/models/organisation_manager/membership'
require './app/models/billing_manager/subscription'

module OrganisationManagerServices
  class AcceptOwnershipTransferService < Service

    def execute
      token = params[:transfer_token]
      JWT.decode(token, Figaro.env.jwt_secret, true, algorithm: 'HS256')

      @transferee = scoped_memberships.find_by(transfer_token: token).user
      @transferor = @transferee.organisation.owner

      if @transferor.subscription && @transferee.subscription
        transfer_subscription!
      end

      transfer_ownership!

      @transferee.membership
    rescue NoMethodError
      raise ActiveRecord::RecordNotFound
    end

    private

    def scoped_memberships
      current_organisation.memberships
    end

    def transfer_subscription!
      @transferee.subscription.transition_to!(:subscribed, { plan: @transferor.plan } )
      @transferor.subscription.transition_to!(:deleted_subscription, params.to_h)
    end

    def transfer_ownership!
      @transferor.membership.update!(role: 'member')
      @transferee.membership.update!(role: 'owner', transfer_token: nil)
    end

  end
end
