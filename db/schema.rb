# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_24_040018) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "auth_tokens", force: :cascade do |t|
    t.string "token", null: false
    t.string "user_id", null: false
    t.boolean "disabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_auth_tokens_on_token", unique: true
    t.index ["user_id"], name: "index_auth_tokens_on_user_id"
  end

  create_table "token_classes", force: :cascade do |t|
    t.string "token_type", null: false, comment: "ERC20, ERC721, ERC1155"
    t.string "chain", null: false, comment: "ethereum, optimism, solana, etc"
    t.string "address", null: false, comment: "token address"
    t.string "name"
    t.string "symbol"
    t.string "image_url"
    t.string "publisher"
    t.string "publisher_address"
    t.integer "position", default: 0
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "decimals", default: 18
    t.integer "chain_id", default: 0
  end

  create_table "transactions", force: :cascade do |t|
    t.string "user_id"
    t.string "chain"
    t.text "data"
    t.string "status"
    t.string "tx_hash"
    t.decimal "gas_used", precision: 80
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "wallet_id"
    t.string "memo"
  end

  create_table "users", id: :string, force: :cascade do |t|
    t.string "handle"
    t.string "email"
    t.string "phone"
    t.string "image_url"
    t.jsonb "encrypted_keys"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "evm_chain_address"
    t.string "evm_chain_active_key"
    t.integer "remaining_gas_credits", default: 0, null: false
    t.decimal "total_used_gas_credits", precision: 80, default: "0", null: false
    t.string "encrypted_password"
    t.boolean "phone_verified", default: false
    t.integer "transaction_count", default: 0, null: false
    t.boolean "can_send_badge", default: false
    t.jsonb "contact_list"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["handle"], name: "index_users_on_handle", unique: true
    t.index ["phone"], name: "index_users_on_phone", unique: true
  end

  create_table "verification_tokens", force: :cascade do |t|
    t.string "context", null: false
    t.string "sent_to", null: false
    t.string "code", null: false
    t.datetime "expires_at", null: false
    t.boolean "used", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "wallets", id: :string, force: :cascade do |t|
    t.string "user_id"
    t.string "name"
    t.string "wallet_type"
    t.string "chain"
    t.string "evm_chain_address"
    t.string "evm_chain_active_key"
    t.jsonb "encrypted_keys"
    t.string "format"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "auth_tokens", "users"
end
