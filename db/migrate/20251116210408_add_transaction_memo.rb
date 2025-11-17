class AddTransactionMemo < ActiveRecord::Migration[8.0]
  def change
    add_column :transactions, :memo, :string
  end
end
