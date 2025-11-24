class AddUserContacts < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :contact_list, :jsonb
  end
end
