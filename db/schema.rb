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

ActiveRecord::Schema[8.0].define(version: 2025_06_10_005508) do
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

  create_table "transactions", force: :cascade do |t|
    t.string "user_id"
    t.string "chain"
    t.text "data"
    t.string "status"
    t.string "tx_hash"
    t.bigint "gas_used"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.integer "total_used_gas_credits", default: 0, null: false
    t.string "encrypted_password"
    t.boolean "phone_verified", default: false
    t.integer "transaction_count", default: 0, null: false
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

  add_foreign_key "auth_tokens", "users"
end
