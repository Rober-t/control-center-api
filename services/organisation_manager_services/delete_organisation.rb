require './lib/service'
require './app/models/organisation_manager/organisation'
require './app/models/organisation_manager/user'


module OrganisationManagerServices
  class DeleteOrganisationService < Service

    def execute
      raise Errors::Forbidden unless current_user.owner?
      cancel_subscription
      current_organisation.destroy!
      current_user.destroy!
    end

    private

    def cancel_subscription
      if current_user.subscription
        current_user.subscription.transition_to!(:deleted_subscription, params)
      end
    end

  end
end
