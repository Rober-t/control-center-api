require './app/models/support_manager/ticket'
require './app/models/support_manager/comment'

module SupportManagerHelpers

  def scoped_tickets
    SupportManager::Ticket.where(organisation_id: current_organisation.id)
  end

  def scoped_comments
     SupportManager::Comment.where(organisation_id: current_organisation.id)
  end

end
