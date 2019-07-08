class CreateTickets < ActiveRecord::Migration[5.0]
  def change
    create_table :tickets do |t|
      t.string :subject, index: true
      t.text :description
      t.integer :user_id, index: true
      t.integer :organisation_id, index: true
      t.integer :node_id, index: true
      t.string :status, index: true

      t.timestamps null: false
    end
  end
end
