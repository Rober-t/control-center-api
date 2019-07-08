class SupportManager
  class Ticket < ActiveRecord::Base

    STATUS = %w(open closed action_required)

    validates :status, :subject, :description, :user_id, :organisation_id, presence: true
    validates :status, :inclusion => { :in => STATUS }

    has_many :comments, dependent: :destroy

    private

    def type
      self.class.name.split('::').last || ''
    end

    class Entity < Grape::Entity
      expose :type,
             :id,
             :status,
             :subject,
             :description,
             :user_id,
             :organisation_id,
             :node_id
    end

  end
end
