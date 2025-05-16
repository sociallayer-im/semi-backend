class AddUserChainInfo < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :evm_chain_address, :string
    add_column :users, :evm_chain_active_key, :string
    add_column :users, :remaining_gas_credits, :integer, default: 0, null: false
    add_column :users, :total_used_gas_credits, :integer, default: 0, null: false
  end
end
