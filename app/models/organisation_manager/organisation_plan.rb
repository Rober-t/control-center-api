require './app/models/organisation_manager/user'
require './app/models/billing_manager/subscription'

class OrganisationManager
  class OrganisationPlan

    def initialize(user)
      @user = user
    end

    def plan
      if owner.subscription && owner.subscription.active?
        owner.subscription.plan
      else
        owner.access.plan
      end
    end

    def state
      if owner.subscription && owner.subscription.active?
        owner.subscription.state
      else
        owner.access.state
      end
    end

    private

    def owner
      @user.organisation.owner
    end

  end
end
