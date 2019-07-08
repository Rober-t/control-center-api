class CreateOrganisations < ActiveRecord::Migration[5.0]
  def change
    create_table :organisations do |t|
      t.string :name, :index => true, :unique => true

      t.timestamps :null => false
    end
  end
end
