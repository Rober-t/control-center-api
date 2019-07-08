class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.text :body
      t.integer :organisation_id, index: true
      t.integer :ticket_id, index: true
      t.integer :author_id, index: true
      t.string :author, index: true

      t.timestamps null: false
    end
  end
end
