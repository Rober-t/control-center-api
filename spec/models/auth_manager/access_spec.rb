require 'spec_helper'
require './app/models/auth_manager/access'

describe AuthManager::Access do

  before do
    @user = current_user
  end

  it 'has a valid factory' do
    expect(@user.access).to be_valid
  end

  describe "#plan" do
    it "returns the correct plan for the user" do
      acces = @user.create_access(start_date: Date.today - 1.day, end_date: Date.today + 1.day, level: "pro")
      expect(@user.access.plan).to eq "pro"
    end
  end

  describe "#state" do
    context "when user's access is active" do
      it "returns the correct state" do
        acces = @user.create_access(start_date: Date.today - 1.day, end_date: Date.today + 1.day, level: "pro")
        expect(@user.access.state).to eq :active
      end
    end

    context "when the user's access is inactive" do
      it "returns the correct state" do
        acces = @user.create_access(start_date: Date.today - 2.day, end_date: Date.today - 1.day, level: "pro")
        expect(@user.access.state).to eq :inactive
      end
    end
  end
end
