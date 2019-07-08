require 'spec_helper'
require './services/organisation_manager_services/send_confirmation_email'
require 'timecop'

describe OrganisationManagerServices::SendConfirmationEmailService do

  before do
    Timecop.freeze(Time.local(1790))
  end

  it "updates confirmation attributes" do
    params = { email: current_user.email }

    service = OrganisationManagerServices::SendConfirmationEmailService.new(params)

    result = service.run
    subject = current_user.reload

    expect(result).to eq true
    expect(subject.registration_token).not_to be nil
  end

  after do
    Timecop.return
  end

end
