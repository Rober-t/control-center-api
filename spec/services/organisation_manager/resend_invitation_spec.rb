require 'spec_helper'
require './services/organisation_manager_services/resend_invitation'
require 'timecop'

describe OrganisationManagerServices::ResendInvitationService do

  before do
    Timecop.freeze(Time.local(1790))
  end

  it "resends invitation" do
    params = { email: current_user.email }

    service = OrganisationManagerServices::ResendInvitationService.new(
      params,
      current_organisation, 
      current_user
    )

    expect(service.run).to eq true
  end

  after do
    Timecop.return
  end

end
