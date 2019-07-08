require 'spec_helper'
require './services/organisation_manager_services/create_account'
require './app/models/organisation_manager/organisation'
require './app/models/organisation_manager/user'
require './app/models/auth_manager/access'
require './app/mailers/mailer'

describe OrganisationManagerServices::CreateAccountService do
  include Mail::Matchers

  before(:each) do
    Mail::TestMailer.deliveries.clear
  end

  it "creates a new user and organisation with access" do
    params = {
        admin: { email: "new_user@testing.com" },
        name: "Test Org"
    }

    service = OrganisationManagerServices::CreateAccountService.new(
      params,
      current_organisation,
      current_user
    )

    subject = service.run
    expect(subject[:organisation]).to be_instance_of OrganisationManager::Organisation
    expect(subject[:user]).to be_instance_of OrganisationManager::User
    expect(subject[:user].access).to be_instance_of AuthManager::Access
  end
  
end
