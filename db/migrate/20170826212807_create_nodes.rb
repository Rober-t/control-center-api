class CreateNodes < ActiveRecord::Migration[5.0]
  def change
    create_table :nodes do |t|
      t.string :name, index: true
      t.string :url
      t.integer :organisation_id, index: true
      t.boolean :verified, default: false

      t.timestamps null: false
    end

    add_index :nodes, [:name, :organisation_id], unique: true
  end
end




