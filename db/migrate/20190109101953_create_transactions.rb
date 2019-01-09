class CreateTransactions < ActiveRecord::Migration[5.1]
  def change
    create_table :transactions do |t|
      t.integer :account_id
      t.string :description
      t.float :amount
      t.string :currency
      t.date :made_on
      t.timestamps null: false
    end
  end
end
