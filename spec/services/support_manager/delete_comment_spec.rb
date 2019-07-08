require 'spec_helper'
require './app/models/support_manager/ticket'
require './app/models/support_manager/comment'
require './app/models/data_manager/node'
require './services/support_manager_services/create_comment'
require './services/support_manager_services/delete_comment'
require './services/support_manager_services/create_ticket'

describe SupportManagerServices::DeleteCommentService do

  before do
    @node = DataManager::Node.create!(
        name: 'test', url: "http://www.my-server.com", organisation_id: current_organisation.id
      )

      ticket_params = {
        node_id: @node.id,
        subject: "new ticket",
        description: "ticket description",
      }

      @ticket = SupportManagerServices::CreateTicketService.new(
        ticket_params,
        current_organisation,
        current_user
      ).run

      comment_params = {
        ticket_id: @ticket.id,
        body: "This is a test."
      }

      @comment = SupportManagerServices::CreateCommentService.new(
        comment_params,
        current_organisation,
        current_user
      ).run
  end

  context "with correct params" do
    it 'deletes ticket' do
      params = { id: @comment.id }

      service = SupportManagerServices::DeleteCommentService.new(params, current_organisation, current_user)

      subject = service.run
      expect(subject).to be_instance_of SupportManager::Comment
      expect(subject.destroyed?).to eq true
    end
  end
  
end

