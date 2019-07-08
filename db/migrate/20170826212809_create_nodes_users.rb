class CreateNodesUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :nodes_users, :id => false do |t|
      t.integer :node_id, index: true
      t.integer :user_id, index: true
    end
  end
end
