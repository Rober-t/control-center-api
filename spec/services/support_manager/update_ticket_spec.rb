require 'spec_helper'
require './app/models/support_manager/ticket'
require './app/models/data_manager/node'
require './services/support_manager_services/create_ticket'
require './services/support_manager_services/update_ticket'

describe SupportManagerServices::UpdateTicketService do

  before do
    @node = DataManager::Node.create!(
      name: 'test', url: "http://www.my-server.com", organisation_id: current_organisation.id
    )

    params = {
      node_id: @node.id,
      subject: "new ticket",
      description: "ticket description",
    }

    @ticket = SupportManagerServices::CreateTicketService.new(
      params,
      current_organisation,
      current_user
    ).run
  end

  context "with correct params" do
    it 'updates ticket' do
      params = {
        id: @ticket.id,
        subject: "new ticket subject",
        description: "updated description",
        status: "action_required",
      }

      service = SupportManagerServices::UpdateTicketService.new(params, current_organisation, current_user)

      subject = service.run
      expect(subject).to be_instance_of SupportManager::Ticket
      expect(subject.subject).to eq "new ticket subject"
      expect(subject.description).to eq "updated description"
      expect(subject.status).to eq "action_required"
    end
  end
  
end

