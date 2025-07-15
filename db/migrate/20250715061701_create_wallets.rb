class CreateWallets < ActiveRecord::Migration[8.0]
  def change
    create_table :wallets, id: :string do |t|
      t.string :user_id
      t.string :name
      t.string :wallet_type
      t.string :chain
      t.string :evm_chain_address
      t.string :evm_chain_active_key
      t.jsonb :encrypted_keys
      t.string :format

      t.timestamps
    end

    add_column :transactions, :wallet_id, :string
  end
end
