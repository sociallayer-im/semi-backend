class AddUserPhoneVerified < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :phone_verified, :boolean, default: false
  end
end
