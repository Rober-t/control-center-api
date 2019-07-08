require 'bcrypt'
require './lib/user_token_auth'
require './lib/permissions'
require './app/models/organisation_manager/organisation_plan'
require './app/models/auth_manager/access'
require './app/models/billing_manager/subscription'

class OrganisationManager
  class User < ActiveRecord::Base
    include BCrypt
    include UserTokenAuth
    include Permissions

    has_secure_password(validations: false)

    has_one :membership, dependent: :destroy
    has_one :organisation, through: :membership
    has_one :subscription, dependent: :destroy, class_name: "BillingManager::Subscription"
    has_one :access, dependent: :destroy, class_name: "AuthManager::Access"

    validates :email, presence: true, uniqueness: true

    delegate :role, :owner?, to: :membership
    delegate :plan, :state, to: :organisation_plan

    def organisation_plan
      @plan ||= OrganisationPlan.new(self)
    end

    private

    def type
      self.class.name.split('::').last || ''
    end

    class Entity < Grape::Entity
      expose :type,
             :id,
             :email,
             :name
    end

  end
end
