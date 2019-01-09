class CreateAccounts < ActiveRecord::Migration[5.1]
  def change
    create_table :accounts do |t|
      t.integer :connection_id
      t.string :name
      t.float :balance
      t.string :currency
      t.timestamps null: false
    end
  end
end
