class CreateVerificationTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :verification_tokens do |t|
      t.string :context, null: false
      t.string :sent_to, null: false
      t.string :code, null: false
      t.datetime :expires_at, null: false
      t.boolean :used, null: false, default: false

      t.timestamps
    end
  end
end