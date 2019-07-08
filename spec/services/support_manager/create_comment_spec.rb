require 'spec_helper'
require './app/models/support_manager/ticket'
require './app/models/support_manager/comment'
require './app/models/data_manager/node'
require './services/support_manager_services/create_comment'
require './services/support_manager_services/create_ticket'

describe SupportManagerServices::CreateTicketService do
  
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
    it 'creates comment' do
      params = {
        ticket_id: @ticket.id,
        body: "This is a test."
      }

      service = SupportManagerServices::CreateCommentService.new(
        params,
        current_organisation,
        current_user
      )

      subject = service.run
      expect(subject).to be_instance_of SupportManager::Comment
      expect(subject.body).to eq "This is a test."
      expect(subject.author).to eq current_user.email
    end
  end

end

