class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.string :user_id
      t.string :chain
      t.text :data
      t.string :status
      t.string :tx_hash
      t.bigint :gas_used

      t.timestamps
    end

    add_column :users, :transaction_count, :integer, default: 0, null: false
  end
end
