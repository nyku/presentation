class CreateLookupUser < ActiveRecord::Migration[5.1]
  def change
    create_table :lookup_users do |t|
      t.string :email
      t.string :app_id
      t.string :secret
      t.string :shard
    end
  end
end
