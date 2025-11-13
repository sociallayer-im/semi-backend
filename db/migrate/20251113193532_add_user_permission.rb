class AddUserPermission < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :can_send_badge, :boolean, default: false
  end
end
