class AuthManager
  class Access < ActiveRecord::Base

    ALL_PLANS = %w(free pro enterprise)

    validates :level, :start_date, :user_id, presence: true
    validates :user_id, uniqueness: true
    validates :level, inclusion: { :in => ALL_PLANS }
    validates_presence_of :end_date, unless: Proc.new { |a| a.level == 'free' }

    def plan
      level
    end

    def state
      active? ? :active : :inactive
    end

    def active?
      return true unless end_date
      start_date <= Date.today && end_date >= Date.today
    end

    def user
      User.find(user_id)
    end

    private

    def type
      self.class.name.split('::').last || ''
    end

  end
end
