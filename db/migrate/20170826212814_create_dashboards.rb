class CreateDashboards < ActiveRecord::Migration[5.0]
  def change
    create_table :dashboards do |t|
      t.string :name, index: true
      t.integer :organisation_id, index: true
      t.json :tree

      t.timestamps null: false
    end

    add_index :dashboards, [:name, :organisation_id], unique: true
  end
end




