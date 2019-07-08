class CreateSubscriptionTransitions < ActiveRecord::Migration[5.0]
  def change
    create_table :subscription_transitions do |t|
      t.string :to_state
      t.json :metadata
      t.integer :sort_key
      t.integer :subscription_id
      t.boolean :most_recent
      t.timestamps null: false
    end
    add_index :subscription_transitions, [:subscription_id, :sort_key], unique: true, name: "index_subscription_transitions_#{:parent_sort}"
    add_index :subscription_transitions, [:subscription_id, :most_recent], unique: true, where: "most_recent", name: "index_subscription_transitions_#{:parent_most_recent}"
  end
end
