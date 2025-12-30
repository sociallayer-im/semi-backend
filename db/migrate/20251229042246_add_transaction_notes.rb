class AddTransactionNotes < ActiveRecord::Migration[8.0]
  def change
    add_column :transactions, :sender_note, :string
    add_column :transactions, :receiver_note, :string
    add_column :transactions, :receiver_address, :string
    add_column :transactions, :sender_address, :string
  end
end
