class CreateAuthTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :auth_tokens do |t|
      t.string :token, null: false
      t.references :user, null: false, foreign_key: true, type: :string
      t.boolean :disabled, null: false, default: false

      t.timestamps
    end
    add_index :auth_tokens, :token, unique: true
  end
end