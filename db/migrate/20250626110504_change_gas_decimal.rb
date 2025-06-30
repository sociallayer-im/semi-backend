class ChangeGasDecimal < ActiveRecord::Migration[8.0]
  def change
    change_column :transactions, :gas_used, :decimal, precision: 80, scale: 0
    change_column :users, :total_used_gas_credits, :decimal, precision: 80, scale: 0

  end
end
