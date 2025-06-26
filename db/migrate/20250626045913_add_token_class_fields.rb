class AddTokenClassFields < ActiveRecord::Migration[8.0]
  def change
    add_column :token_classes, :decimals, :integer, default: 18
    add_column :token_classes, :chain_id, :integer, default: 0
  end
end
