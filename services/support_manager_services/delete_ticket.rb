require './lib/service'
require './app/models/support_manager/ticket'
require './app/models/support_manager/comment'

module SupportManagerServices
  class DeleteTicketService < Service

    def execute
      ticket = scoped_tickets.where(id: params[:id], user_id: current_user.id).first
      ticket.destroy!
    end

    private

    def scoped_tickets
      SupportManager::Ticket.where(organisation_id: current_organisation.id)
    end

  end
end
