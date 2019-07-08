require 'spec_helper'
require './app/models/support_manager/ticket'
require './app/models/support_manager/comment'
require './app/models/data_manager/node'
require './services/support_manager_services/create_comment'
require './services/support_manager_services/update_comment'
require './services/support_manager_services/create_ticket'

describe SupportManagerServices::UpdateCommentService do

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
    it 'updates comment' do
      params = {
        id: @comment.id,
        body: "This is a test - UPDATE."
      }

      service = SupportManagerServices::UpdateCommentService.new(
        params,
        current_organisation,
        current_user
      )

      subject = service.run
      expect(subject).to be_instance_of SupportManager::Comment
      expect(subject.body).to eq "This is a test - UPDATE."
      expect(subject.author).to eq current_user.email
    end
  end

end

