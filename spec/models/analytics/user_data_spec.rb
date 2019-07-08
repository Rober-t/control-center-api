require 'spec_helper'
require './app/models/analytics/user_data'
require './app/models/organisation_manager/user'
require './app/models/organisation_manager/organisation'

describe Analytics::UserData do

  before do
    @user = current_user
    allow(Analytics::Analytics).to receive(:identify)
    allow(Analytics::Analytics).to receive(:track)
  end

  describe '#track_event' do
    it 'notifies Analytics when a new event occurs' do
      UserData = Analytics::UserData.new(@user)

      UserData.track_event("some event", { organisation_plan: "new_plan" }, { organisation_state: "past_due" } )

      expect(Analytics::Analytics).to have_received(:identify).with(
        {
          :user_id => @user.email,
          :traits => {
            :name => @user.name,
            :organisation => @user.organisation.try(:name),
            :role => @user.membership.role,
            :organisation_plan => @user.plan,
            :organisation_state => 'past_due'
          }.reject { |key, value| value.nil? }
        }
      )

      expect(Analytics::Analytics).to have_received(:track).with(
        {
          user_id: @user.email,
          event: 'some event',
          properties: { organisation_plan: "new_plan" }
        }
      )
    end
  end
  
end
