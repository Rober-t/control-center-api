class CreateAccesses < ActiveRecord::Migration[5.0]
  def change
    create_table :accesses do |t|
      t.string :level, :default => 'free', :index => true
      t.datetime :start_date
      t.datetime :end_date, :index => true
      t.integer :user_id, :index => true

      t.timestamps :null => false
    end
  end
end
