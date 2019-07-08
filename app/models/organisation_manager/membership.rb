class OrganisationManager
  class Membership < ActiveRecord::Base
    ROLES = %w(owner admin member restricted)

    belongs_to :user
    belongs_to :organisation

    validates :role, :presence => true, :inclusion => { :in => ROLES }
    validates_uniqueness_of :role, scope: :organisation_id, conditions: -> { where(role: 'owner') }
    validates :user, presence: true
    validates :organisation, presence: true

    def owner?
      role == 'owner'
    end

    private

    def type
      self.class.name.split('::').last || ''
    end

    class Entity < Grape::Entity
      expose :id,
             :user_id,
             :organisation_id,
             :role,
             :type
    end

  end
end


