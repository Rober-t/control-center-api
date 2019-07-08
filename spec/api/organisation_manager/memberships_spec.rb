require 'spec_helper'

describe "Memberships" do

  before(:each) do
    set_auth_header current_user
  end

  before do
    allow_any_instance_of(StripeMock::Instance).to receive(:get_card_by_token) {
      StripeMock::Data.mock_card Stripe::Util.symbolize_names({})
    }
  end

  describe "GET memberships", autodoc: true do

    before do
      @user1 = OrganisationManager::User.create!(
        email: 'test8@testing.com',
        organisation: current_user.organisation
      )
      @user2 = OrganisationManager::User.create!(
        email: 'test9@testing.com',
        organisation: current_user.organisation
      )
    end

    it "retrieves a list of memberships" do
      get "memberships"

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("memberships")
    end
  end


  describe 'PUT memberships/:id', autodoc: true do
    it 'updates membership' do
      params = { data: { role: "admin" } }

      put "memberships/#{current_user.membership.id}", params

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("membership")
    end
  end

  describe "DELETE memberships/:id", autodoc: true do
    it 'deletes membership' do
      delete "memberships/#{current_user.membership.id}"

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("success")
    end
  end

  describe "GET memberships/:id/actions/pending_transfers", autodoc: true do
    before do
      @transferee = OrganisationManager::User.create!(
        email: 'test9@testing.com',
        organisation: current_user.organisation
      )
      @transferee.membership.update!(
        transfer_token: @transferee.generate_token,
        transferor_id: current_user.id
      )
    end

    it "retrieves list of pending transfer requests" do
      get "memberships/#{current_user.membership.id}/actions/pending_transfers"

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("memberships")
    end
  end

  describe "POST memberships/:id/actions/request_transfer", autodoc: true do
    before do
      @transferor = current_user
      @transferee = OrganisationManager::User.create!(
        email: 'test9@testing.com',
        organisation: current_user.organisation
      )
    end

    it "requests transfer" do
      params = {
        data: {
          email: @transferee.email
        }
      }

      post "memberships/#{@transferor.membership.id}/actions/request_transfer", params

      expect(last_response.status).to eq 201
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("membership")
    end
  end

  describe "POST memberships/:id/actions/accept_transfer", autodoc: true do
    before do
      @transferor = current_user
      @transferee = OrganisationManager::User.create!(
        email: 'test9@testing.com',
        organisation: current_user.organisation
      )
      @transfer_token = @transferee.generate_token

      @transferee.membership.update!(transfer_token: @transfer_token)
      @transferor_subscription = BillingManager::Subscription.new(user_id: @transferor.id)
      @transferor_subscription.transition_to!(:subscribed, {
          email: @transferor.email,
          card_token: stripe_helper.generate_card_token,
          plan: 'pro'
        }
      )

      @transferee_subscription = BillingManager::Subscription.new(user_id: @transferee.id)
      @transferee_subscription.transition_to!(:saved_card, {
        email: @transferee.email,
        card_token: stripe_helper.generate_card_token
        }
      )
      @transferee_subscription.save(validate: false)
    end

    it "accepts transfer" do
      params = {
        data: {
          transfer_token: @transfer_token
        }
      }

      post "memberships/#{@transferor.membership.id}/actions/accept_transfer", params

      expect(last_response.status).to eq 201
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("membership")
    end
  end

  describe "POST memberships/:id/actions/revoke_transfer", autodoc: true do
    before do
      @transferee = OrganisationManager::User.create!(
        email: 'test9@testing.com',
        organisation: current_user.organisation
      )
      @transferee.membership.update!(transfer_token: @transferee.generate_token)
      @transferee_subscription = BillingManager::Subscription.new(user_id: @transferee.id)
      @transferee_subscription.transition_to!(:saved_card, {
          email: @transferee.email,
          card_token: stripe_helper.generate_card_token
        }
      )
      @transferee_subscription.save(validate: false)
    end

    it "revokes transfer request" do
      params = { data: { email: @transferee.email } }
      post "memberships/#{current_user.membership.id}/actions/revoke_transfer", params

      expect(last_response.status).to eq 201
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("success")
      expect(@transferee.membership.reload.transfer_token).to be nil
    end
  end

end

