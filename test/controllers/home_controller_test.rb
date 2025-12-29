require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get root_url
    assert_response :success
    assert_equal({"message" => "Hello, World!"}, JSON.parse(@response.body))
  end

  test "should send sms" do
    # TODO: Set up ENV and stub RPCClient if needed
    post send_sms_url, params: { phone: "1234567890" }
    assert VerificationToken.find_by(context: "phone-login", sent_to: "1234567890")
    assert JSON.parse(@response.body).key?("code")
  end

  test "should signin with valid code" do
    VerificationToken.create(context: "phone-login", sent_to: "1234567890", code: "12345", expires_at: Time.now + 15.minutes)
    post signin_url, params: { phone: "1234567890", code: "12345" }
    assert_response :success
    assert JSON.parse(@response.body).key?("auth_token")
    assert JSON.parse(@response.body).key?("phone")
    assert JSON.parse(@response.body).key?("id")
    assert JSON.parse(@response.body).key?("address_type")
  end

  test "should signin with valid password" do
    post signin_with_password_url, params: { phone: "1234567890", password: "12345" }
    assert_response :success
    assert JSON.parse(@response.body).key?("auth_token")
    assert JSON.parse(@response.body).key?("phone")
    assert JSON.parse(@response.body).key?("id")
    assert JSON.parse(@response.body).key?("address_type")
    user = User.find_by(phone: "1234567890")
    assert BCrypt::Password.new(user.encrypted_password) == "12345"

    post signin_with_password_url, params: { phone: "1234567890", password: "12345" }
    assert_response :success
    assert JSON.parse(@response.body).key?("auth_token")
    assert JSON.parse(@response.body).key?("phone")
    assert JSON.parse(@response.body).key?("id")
    assert JSON.parse(@response.body).key?("address_type")
  end

  test "should signin with valid password for passwordless user" do
    User.create(phone: "1234567890")
    post signin_with_password_url, params: { phone: "1234567890", password: "12345" }
    assert_response :success
    assert JSON.parse(@response.body).key?("auth_token")
    assert JSON.parse(@response.body).key?("phone")
    assert JSON.parse(@response.body).key?("id")
    assert JSON.parse(@response.body).key?("address_type")
    user = User.find_by(phone: "1234567890")
    assert BCrypt::Password.new(user.encrypted_password) == "12345"
  end

  test "should signin with invalid password" do
    User.create(phone: "1234567890", encrypted_password: BCrypt::Password.create("12345"))
    post signin_with_password_url, params: { phone: "1234567890", password: "123456" }
    assert_response :unauthorized
  end

  test "should set handle" do
    user = User.create(phone: "1234567890")
    post set_handle_url, params: { id: user.id, handle: "newhandle" }, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert JSON.parse(@response.body).key?("result")

    get get_by_handle_url, params: { handle: "newhandle" }
    assert_response :success
    assert JSON.parse(@response.body).key?("id")
    assert JSON.parse(@response.body).key?("handle")
  end

  test "should set image url" do
    user = User.create(phone: "1234567890")
    post set_image_url_url, params: { id: user.id, image_url: "http://example.com/image.png" }, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert JSON.parse(@response.body).key?("result")
  end

  test "should set encrypted keys" do
    user = User.create(phone: "1234567890")
    post set_encrypted_keys_url, params: { id: user.id, encrypted_keys: "encrypted_data" }, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert JSON.parse(@response.body).key?("result")
  end

  test "should get encrypted keys" do
    user = User.create(phone: "1234567890")
    get get_encrypted_keys_url, params: { id: user.id }, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert JSON.parse(@response.body).key?("result")
    assert JSON.parse(@response.body).key?("encrypted_keys")
  end

  test "should set evm chain address" do
    user = User.create(phone: "1234567890")
    post set_evm_chain_address_url, params: { id: user.id, evm_chain_address: "0x1234567890", evm_chain_active_key: "0x1234567890" }, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert JSON.parse(@response.body).key?("result")
  end

  test "should get user" do
    user = User.create(phone: "1234567890")
    get get_user_url, params: { id: user.id }
    assert_response :success
    assert JSON.parse(@response.body)["phone"] == "1234567890"
  end

  test "should get me" do
    user = User.create(phone: "1234567890")
    get get_me_url, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert JSON.parse(@response.body).key?("id")
    assert JSON.parse(@response.body).key?("handle")
    assert JSON.parse(@response.body).key?("email")
    assert JSON.parse(@response.body).key?("phone")
    assert JSON.parse(@response.body).key?("image_url")
    assert JSON.parse(@response.body).key?("evm_chain_address")
    assert JSON.parse(@response.body).key?("evm_chain_active_key")
    assert JSON.parse(@response.body).key?("remaining_gas_credits")
  end

  test "should add transaction" do
    user = User.create(phone: "1234567890")
    post add_transaction_url, params: {
      tx_hash: "0x1234567890",
      gas_used: 100,
      status: "success",
      chain: "evm",
      data: "data",
      memo: "test memo",
      sender_note: "s note",
      receiver_note: "r note",
      sender_address: "0x123",
      receiver_address: "0x456"
    }, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert JSON.parse(@response.body).key?("result")

    tx = Transaction.find_by(tx_hash: "0x1234567890")
    assert_equal "test memo", tx.memo
    assert_equal "s note", tx.sender_note
    assert_equal "r note", tx.receiver_note
    assert_equal "0x123", tx.sender_address
    assert_equal "0x456", tx.receiver_address

    get get_transactions_url, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert JSON.parse(@response.body).key?("transactions")

    get remaining_free_transactions_url, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert JSON.parse(@response.body).key?("remaining_free_transactions")
  end

  test "should signin with email" do
    post send_email_url, params: { email: "delivered@resend.dev" }
    assert_response :success
    assert JSON.parse(@response.body).key?("result")
    assert JSON.parse(@response.body).key?("email")
    # p ActionMailer::Base.deliveries.last
    # assert ActionMailer::Base.deliveries.last.to.include?("delivered@resend.dev")
    # assert ActionMailer::Base.deliveries.last.subject == "Semi Sign-In"

    VerificationToken.create(context: "email-login", sent_to: "delivered@resend.dev", code: "12345", expires_at: Time.now + 15.minutes)
    post signin_with_email_url, params: { email: "delivered@resend.dev", code: "12345" }
    assert_response :success
    assert JSON.parse(@response.body).key?("result")
    assert JSON.parse(@response.body).key?("email")
  end

  test "should add transaction with gas credits" do
    ADMIN_KEY = "1234567890"
    ENV["ADMIN_KEY"] = ADMIN_KEY
    user = User.create(phone: "1234567890")
    post add_transaction_with_gas_credits_url, params: {
      id: user.id,
      tx_hash: "0x1234567890",
      gas_used: 100,
      status: "success",
      chain: "evm",
      data: "data",
      sender_note: "s note",
      receiver_note: "r note",
      sender_address: "0x123",
      receiver_address: "0x456"
    }, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert JSON.parse(@response.body).key?("result")

    tx = Transaction.find_by(tx_hash: "0x1234567890")
    assert_equal "s note", tx.sender_note
    assert_equal "r note", tx.receiver_note
    assert_equal "0x123", tx.sender_address
    assert_equal "0x456", tx.receiver_address
  end

  test "should set transaction note as owner" do
    user = User.create(phone: "1234567890")
    tx = Transaction.create(user: user, tx_hash: "0xowner", status: "success")
    post set_transaction_note_url, params: { id: tx.id, sender_note: "owner note" }, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert_equal "owner note", tx.reload.sender_note
  end

  test "should set transaction note as sender" do
    user = User.create(phone: "1234567890", evm_chain_address: "0xsender")
    other_user = User.create(phone: "0987654321")
    tx = Transaction.create(user: other_user, tx_hash: "0xsender_tx", sender_address: "0xsender")
    post set_transaction_note_url, params: { id: tx.id, sender_note: "sender note" }, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert_equal "sender note", tx.reload.sender_note
  end

  test "should set transaction note as receiver" do
    user = User.create(phone: "1234567890", evm_chain_address: "0xreceiver")
    other_user = User.create(phone: "0987654321")
    tx = Transaction.create(user: other_user, tx_hash: "0xreceiver_tx", receiver_address: "0xreceiver")
    post set_transaction_note_url, params: { id: tx.id, receiver_note: "receiver note" }, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert_equal "receiver note", tx.reload.receiver_note
  end

  test "should fail set transaction note if unauthorized" do
    user = User.create(phone: "1234567890")
    other_user = User.create(phone: "0987654321")
    tx = Transaction.create(user: other_user, tx_hash: "0xunauthorized", sender_address: "0xsomeone", receiver_address: "0xelse")
    post set_transaction_note_url, params: { id: tx.id, sender_note: "hacker note" }, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :bad_request
  end

  test "should get transactions with txhashes filter" do
    user = User.create(phone: "1234567890")
    tx1 = Transaction.create(user: user, tx_hash: "0x1", status: "success")
    tx2 = Transaction.create(user: user, tx_hash: "0x2", status: "success")
    tx3 = Transaction.create(user: user, tx_hash: "0x3", status: "success")

    get get_transactions_url, params: { txhashes: "0x1,0x3" }, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    txs = JSON.parse(@response.body)["transactions"]
    assert_equal 2, txs.length
    hashes = txs.map { |t| t["tx_hash"] }
    assert_includes hashes, "0x1"
    assert_includes hashes, "0x3"
    assert_not_includes hashes, "0x2"
  end

  test "should get token classes" do
    user = User.create(phone: "1234567890")
    post add_token_class_url, params: { token_type: "ERC20", chain: "ethereum", chain_id: 1, address: "0x1234567890", name: "Test Token", symbol: "TT", decimals: 18, image_url: "http://example.com/image.png", publisher: "Test Publisher", publisher_address: "0x1234567890", position: 0, description: "Test Description" }, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert JSON.parse(@response.body).key?("result")
    assert TokenClass.find_by(address: "0x1234567890").decimals == 18
    assert TokenClass.find_by(address: "0x1234567890").chain_id == 1

    get get_token_classes_url
    assert_response :success
    assert JSON.parse(@response.body).key?("result")
    assert JSON.parse(@response.body).key?("token_classes")
  end

  test "should add wallet" do
    user = User.create(phone: "1234567890")
    post add_wallet_url, params: { name: "Test Wallet", wallet_type: "evm", chain: "ethereum", evm_chain_address: "0x1234567890", evm_chain_active_key: "0x1234567890", encrypted_keys: "encrypted_data", format: "json" }, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert JSON.parse(@response.body).key?("result")
    assert JSON.parse(@response.body).key?("wallet")

    get get_wallets_url, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert JSON.parse(@response.body).key?("result")
    assert JSON.parse(@response.body).key?("wallets")

    assert JSON.parse(@response.body)["wallets"].first["id"] == Wallet.find_by(name: "Test Wallet").id
    assert JSON.parse(@response.body)["wallets"].first["name"] == "Test Wallet"
    assert JSON.parse(@response.body)["wallets"].first["wallet_type"] == "evm"

    post remove_wallet_url, params: { id: Wallet.find_by(name: "Test Wallet").id }, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert JSON.parse(@response.body).key?("result")

    get get_wallets_url, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
  end

  test "should set and get contacts" do
    user = User.create(phone: "1234567890")
    contact_list = [{ "name" => "Alice", "phone" => "9876543210" }, { "name" => "Bob", "phone" => "5555555555" }]

    post set_contacts_url, params: { id: user.id, contact_list: contact_list }, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert_equal "ok", JSON.parse(@response.body)["result"]

    user.reload
    assert_equal contact_list, user.contact_list

    get get_contacts_url, params: { id: user.id }
    assert_response :success
    assert_equal "ok", JSON.parse(@response.body)["result"]
    assert_equal contact_list, JSON.parse(@response.body)["contacts"]
  end

  test "should fail set_contacts without auth" do
    user = User.create(phone: "1234567890")
    other_user = User.create(phone: "9999999999")
    contact_list = [{ "name" => "Alice", "phone" => "9876543210" }]

    post set_contacts_url, params: { id: user.id, contact_list: contact_list }, headers: { "Authorization" => "Bearer #{other_user.gen_auth_token}" }
    assert_response :bad_request
    assert_equal "Invalid Auth Token", JSON.parse(@response.body)["message"]
  end

  test "should fail get_contacts for non-existent user" do
    get get_contacts_url, params: { id: "nonexistent" }
    assert_response :bad_request
    assert_equal "User Not Found", JSON.parse(@response.body)["message"]
  end

end
