class SupportManager
  class Comment < ActiveRecord::Base
    belongs_to :ticket

    validates :body, :ticket, :author_id, :author, presence: true

    private

    def type
      self.class.name.split('::').last || ''
    end

    class Entity < Grape::Entity
      expose :type,
             :id,
             :body,
             :ticket_id,
             :author,
             :author_id,
             :created_at,
             :updated_at
    end

  end
end
