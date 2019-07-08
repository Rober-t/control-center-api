require './lib/service'
require './app/models/support_manager/ticket'
require './app/models/support_manager/comment'

module SupportManagerServices
  class CreateCommentService < Service

    def execute
      ticket = scoped_tickets.find(params[:ticket_id])
      params.merge!(
        author:  current_user.email,
        organisation_id: current_organisation.id,
        author_id: current_user.id
      )
      ticket.comments.create!(params.to_h)
    end

    private

    def scoped_tickets
      SupportManager::Ticket.where(organisation_id: current_organisation.id)
    end

  end
end
