class DataManager
  class Node < ActiveRecord::Base
  
    validates :name, :url, presence: true, uniqueness: true
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
             :url,
             :verified
    end

  end
end