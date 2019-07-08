require 'spec_helper'
require './app/models/support_manager/ticket'
require './app/models/data_manager/node'
require './services/support_manager_services/create_ticket'
require './services/support_manager_services/delete_ticket'

describe SupportManagerServices::DeleteTicketService do

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
    it 'deletes ticket' do
      params = { id: @ticket.id }

      service = SupportManagerServices::DeleteTicketService.new(params, current_organisation, current_user)

      subject = service.run
      expect(subject).to be_instance_of SupportManager::Ticket
      expect(subject.destroyed?).to eq true
    end
  end
  
end

