class DataManager
  class Dashboard < ActiveRecord::Base
  
    validates :name, :tree, presence: true, uniqueness: true
    validates :organisation_id, presence: true

    private

    def type
      self.class.name.split('::').last || ''
    end

    class Entity < Grape::Entity
      expose :type,
             :id,
             :organisation_id,
             :name,
             :tree
    end

  end
end