require 'spec_helper'
require './lib/permissions'

describe Permissions do

  before do
    @user = current_user
  end

  describe "#can_do?" do
    context "when the user has permission" do
      it "gives authorization" do
        expect(@user.can_do?(:read)).to eq true
        expect(@user.can_do?(:invite)).to eq true
      end
    end

    context "when the user does not have permission" do
      it "does not give authorization" do
        expect(@user.can_do?(:manage_org)).to eq true
        expect(@user.can_do?(:all)).to eq true

        @user.membership.update!(role: 'member')

        expect(@user.can_do?(:manage_org)).to eq false
        expect(@user.can_do?(:all)).to eq false
      end
    end
  end

end

