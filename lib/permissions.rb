module Permissions

  PERMISSIONS = {
    read:               %w(owner admin member restricted),
    invite:             %w(owner admin member),
    manage_tickets:     %w(owner admin member),
    manage_comments:    %w(owner admin member),
    manage_nodes:       %w(owner admin member),
    manage_dashboards:  %w(owner admin member),
    moderate:           %w(owner admin),
    manage_org:         %w(owner admin),
    all:                %w(owner)
  }

  def can_do?(action)
    PERMISSIONS[action.to_sym].include?(self.role)
  rescue
    raise Errors::Forbidden
  end

end
