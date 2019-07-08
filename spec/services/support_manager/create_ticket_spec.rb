require 'spec_helper'
require './app/models/support_manager/ticket'
require './app/models/data_manager/node'
require './services/support_manager_services/create_ticket'

describe SupportManagerServices::CreateTicketService do

  before do
    @node = DataManager::Node.create!(
      name: 'test', url: "http://www.my-server.com", organisation_id: current_organisation.id
    )
  end

  context "with correct params" do
    it 'creates ticket' do
      params = {
        node_id: @node.id,
        subject: "new ticket",
        description: "ticket description",
      }

      service = SupportManagerServices::CreateTicketService.new(
        params,
        current_organisation,
        current_user
      )

      subject = service.run
      expect(subject).to be_instance_of SupportManager::Ticket
      expect(subject.subject).to eq "new ticket"
      expect(subject.description).to eq "ticket description"
      expect(subject.status).to eq "open"
    end
  end

end

