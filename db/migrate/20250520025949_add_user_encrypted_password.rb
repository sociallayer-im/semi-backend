class AddUserEncryptedPassword < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :encrypted_password, :string
  end
end
