require './lib/service'
require './app/models/support_manager/ticket'

module SupportManagerServices
  class UpdateTicketService < Service

    def execute
      ticket = find_ticket
      ticket.update!(params)
      ticket
    end

    private

    def find_ticket
      SupportManager::Ticket.where(id: params[:id], user_id: current_user.id).first
    end

  end
end
