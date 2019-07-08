require 'spec_helper'
require './app/models/organisation_manager/user'
require './app/models/organisation_manager/membership'

describe OrganisationManager::Membership do
  context "validations" do

    before do
      @owner = current_user
      @organisation = current_organisation
      @user = OrganisationManager::User.create!(email: 'test2@testing.com')
      @user.update!(organisation: @organisation)
    end

    it 'should not allow more than one owner per organisation' do
      membership_one = @owner.membership
      membership_two = @user.membership

      expect{membership_two.update!(role: 'owner')}.to raise_error(
        ActiveRecord::RecordInvalid
      ).with_message('Validation failed: Role has already been taken')
    end
  end

end
