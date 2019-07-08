require 'spec_helper'
require './services/organisation_manager_services/send_reset_password_email'
require 'timecop'

describe OrganisationManagerServices::SendResetPasswordEmailService do

  before do
    Timecop.freeze(Time.local(1390))
  end

  it "updates reset password attributes" do
    params = { email: current_user.email }

    service = OrganisationManagerServices::SendResetPasswordEmailService.new(
      params,
      current_organisation,
      current_user
    )

    result = service.run

    subject = current_user.reload

    expect(result).to eq true
    expect(subject.reset_password_token).not_to be nil
  end

  after do
    Timecop.return
  end
  
end
