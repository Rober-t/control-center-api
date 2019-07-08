class Service

  def initialize(params, current_organisation=nil, current_user=nil)
    @params = params
    @current_organisation = current_organisation
    @current_user = current_user
  end

  attr_reader :params, :current_organisation, :current_user

  def run
    ActiveRecord::Base.transaction do
      execute
    end
  end

  private

  def execute
    raise NotImplementedError
  end

end
