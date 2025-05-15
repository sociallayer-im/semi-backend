class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :string do |t|
      t.string :handle
      t.string :email
      t.string :phone
      t.string :image_url
      t.jsonb :encrypted_keys

      t.timestamps
    end
    add_index :users, :handle, unique: true
    add_index :users, :email, unique: true
    add_index :users, :phone, unique: true
  end
end