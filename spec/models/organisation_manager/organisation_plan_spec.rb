require 'spec_helper'
require './app/models/organisation_manager/user'
require './app/models/organisation_manager/organisation_plan'

describe OrganisationManager::OrganisationPlan do

  before do
    @user = current_user
    @organisation = current_organisation
  end

  describe '#plan' do
    it "returns correct plan" do
      expect(@user.plan).to eq('free')
    end
  end

  describe '#state' do
    it "returns correct state" do
      expect(@user.state).to eq(:active)
    end
  end

end
