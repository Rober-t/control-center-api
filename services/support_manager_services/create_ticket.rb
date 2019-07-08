require './lib/service'
require './app/models/support_manager/ticket'

module SupportManagerServices
  class CreateTicketService < Service

    def execute
      SupportManager::Ticket.create!(
        organisation_id: current_organisation.id,
        user_id: current_user.id,
        subject: params[:subject],
        description: params[:description],
        node_id: params[:node_id],
        status: "open"
      )
    end

  end
end

