class CreateConnections < ActiveRecord::Migration[5.1]
  def change
    create_table :connections do |t|
      t.integer :user_id
      t.string :name
      t.timestamps null: false
    end
  end
end
