require './app/models/organisation_manager/membership'
require './app/models/support_manager/ticket'
require './app/models/data_manager/dashboard'
require './app/models/data_manager/node'

class OrganisationManager
  class Organisation < ActiveRecord::Base
    has_many :memberships, dependent: :destroy
    has_many :users, through: :memberships, dependent: :destroy

    has_many :tickets, dependent: :destroy, class_name: "SupportManager::Ticket"
    has_many :dashboards, dependent: :destroy, class_name: "DataManager::Dashboard"
    has_many :nodes, dependent: :destroy, class_name: "DataManager::Node"

    validates :name, presence: true, uniqueness: true

    validate :has_owner

    def owner
      memberships.find_by(role: 'owner').user
    end

    private

    def has_owner
      memberships.exists?(role: 'owner')
    end

    def type
      self.class.name.split('::').last || ''
    end

    class Entity < Grape::Entity
      expose :type,
             :id,
             :name
    end

  end
end
