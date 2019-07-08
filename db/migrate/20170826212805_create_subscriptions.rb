class CreateSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :subscriptions do |t|
      t.integer :user_id
      t.string :subscription_id
      t.string :state, default: :inactive
      t.string :plan
      t.string :customer_id
      t.string :current_period_start
      t.string :current_period_end
      t.string :default_card
      t.string :coupon_code
      t.boolean :cancel_at_period_end, default: false

      t.timestamps :null => false
    end

    add_index :subscriptions, :user_id, :unique => true
    add_index :subscriptions, :subscription_id, :unique => true
    add_index :subscriptions, :state
    add_index :subscriptions, :plan
  end
end
