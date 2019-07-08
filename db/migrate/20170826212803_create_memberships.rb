class CreateMemberships < ActiveRecord::Migration[5.0]
  def change
    create_table :memberships do |t|
      t.string :role, :default => 'member', index: true
      t.integer :user_id
      t.integer :organisation_id
      t.string  :transfer_token, :index => true, :unique => true
      t.string  :transferor_id, :index => true

      t.timestamps :null => false
    end

    add_index :memberships, [:user_id, :organisation_id], unique: true
  end
end

