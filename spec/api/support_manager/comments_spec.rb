require 'spec_helper'
require './app/models/organisation_manager/organisation'
require './app/models/data_manager/node'
require './app/models/organisation_manager/user'
require './app/models/support_manager/comment'

require './services/support_manager_services/create_ticket'
require './services/support_manager_services/create_comment'

describe "Comments" do

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
      current_user
    ).run

    @comment = SupportManagerServices::CreateCommentService.new({
        ticket_id: @ticket.id,
        body: 'some body',
        author_id: current_user.id
      },
      current_organisation,
      current_user
    ).run

    @other_users_comment = SupportManagerServices::CreateCommentService.new({
        ticket_id: @ticket.id,
        body: 'some body',
        author_id: 23
      },
      current_organisation,
      current_user
    ).run
  end

  describe "GET comments", autodoc: true do
    it "retrieves a list of comments" do
      params = { ticket_id: @ticket.id }

      get "comments", params

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("comments")
    end
  end

  describe "GET comments/:id", autodoc: true do
    it "retrieves comment" do
      params = { ticket_id: @ticket.id }

      get "comments/#{@comment.id}", params

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("comment")
    end
  end

  describe "POST comments", autodoc: true do
    it "creates comment" do
      params = {
        data: {
          ticket_id: @ticket.id,
          body: 'comment body',
          parent_id: @comment.id,
          author_id: current_user.id
        }
      }

      post "comments", params

      expect(last_response.status).to eq 201
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("comment")
    end
  end

  describe 'PUT comments/:id', autodoc: true do
    it 'updates comment' do
      params = { data: { ticket_id: @ticket.id, body: 'updated comment body' } }

      put "comments/#{@comment.id}", params

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("comment")
    end

    context 'when user is not owner' do
      before do
        current_user.membership.update!(role: 'restricted')
      end

      it 'does not update comment' do
        params = { data: { ticket_id: @ticket.id, body: 'updated comment body' } }

        put "comments/#{@other_users_comment.id}", params

        expect(last_response.status).to eq 403
      end
    end
  end

  describe "DELETE comments/:id", autodoc: true do
    it 'deletes comment' do
      params = { ticket_id: @ticket.id }

      delete "comments/#{@comment.id}", params

      expect(last_response.status).to eq 200
      expect(last_response.header).to be_valid_json
      expect(last_response.body).to match_response_schema("success")
    end

    context 'when user is not owner' do
      before do
        current_user.membership.update!(role: 'member')
      end

      it 'does not delete comment' do
        params = { ticket_id: @ticket.id }

        delete "comments/#{@other_users_comment.id}", params

        expect(last_response.status).to eq 403
      end
    end
  end
end

