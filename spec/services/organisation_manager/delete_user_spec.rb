require 'spec_helper'
require './services/organisation_manager_services/delete_user'
require './services/billing_manager_services/create_subscription'
require './app/models/organisation_manager/organisation'
require './app/models/organisation_manager/membership'
require './app/models/organisation_manager/user'
require './app/models/auth_manager/access'

describe OrganisationManagerServices::DeleteUserService do
  
  before do
    setup_stripe_subscription(current_user)
  end

  it "deletes user" do
    params = {
      id: current_user.id
    }

    service = OrganisationManagerServices::DeleteUserService.new(
      params,
      current_organisation,
      current_user
    )

    subject = service.run
    expect(subject).to be_instance_of OrganisationManager::User
    expect(subject.destroyed?).to eq true
    expect(subject.subscription.destroyed?).to eq true
  end

end
