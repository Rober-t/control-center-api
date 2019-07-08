class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string   :name
      t.string   :email, :index => true, :unique => true
      t.string   :password_digest
      t.string   :jti, index: true

      t.string   :registration_token, :index => true, :unique => true
      t.datetime :confirmed_at

      t.string   :reset_password_token

      t.integer  :invited_by_id, index: true
      t.integer  :invitations_sent, default: 0, index: true

      t.timestamps :null => false
    end
  end
end







