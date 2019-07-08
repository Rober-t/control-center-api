require 'spec_helper'
require './app/models/data_manager/node'
require './services/support_manager_services/create_ticket'

describe "Tickets" do

  before(:each) do
    set_auth_header current_user
  end

  before do
    @node = DataManager::Node.create!(name: 'test', url: "http://www.my-server.com", organisation_id: current_organisation.id)

    @ticket = SupportManagerServices::CreateTicketService.new({
      node_id: @node.id,
      subject: "new ticket",
      description: "ticket description"
    },
    current_organisation,
    current_user).run

    @ticket1 = SupportManagerServices::CreateTicketService.new({
      node_id: @node.id,
      subject: "new ticket one",
      description: "ticket description one"
    },
    current_organisation,
    current_user).run
  end

  describe "GET tickets", autodoc: true do

    it "retrieves list of tickets" do
      get "tickets"

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("tickets")
    end
  end

  describe "GET tickets/:id", autodoc: true do

    it "retrieves a ticket" do
      get "tickets/#{@ticket.id}"

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("ticket")
    end
  end


  describe "POST tickets", autodoc: true do
    it "creates ticket" do
      params = {
        data: {
          subject: 'prepare_vc_report',
          description: 'update for latest quarter',
          node_id: @node.id
        }
      }

      post "tickets", params

      expect(last_response.status).to eq 201
      expect(last_response.header).to be_valid_json
      # expect(last_response.body).to match_response_schema("ticket")
    end
  end

  describe 'PUT tickets/:id', autodoc: true do

    it 'updates ticket' do
      params = { data: { subject: 'new_ticket_name', description: "new_description" } }

      put "tickets/#{@ticket.id}", params

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("ticket")
      expect(@ticket.reload.subject).to eq 'new_ticket_name'
      expect(@ticket.reload.description).to eq "new_description"
    end
  end

  describe "DELETE tickets/:id", autodoc: true do

    it 'deletes ticket' do
      delete "tickets/#{@ticket.id}"

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("success")
    end

    context 'when user is not ticket owner' do

      it 'does not delete ticket' do
        current_user.update(id: 34)

        delete "tickets/#{@ticket1.id}"

        expect(last_response.status).not_to eq 200
        expect(last_response.header).to be_valid_json
        expect(last_response.body).to match_response_schema("error")
        expect(@ticket1.destroyed?).not_to eq true
      end
    end
  end

end

