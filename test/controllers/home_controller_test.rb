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
    post add_transaction_url, params: { tx_hash: "0x1234567890", gas_used: 100, status: "success", chain: "evm", data: "data" }, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert JSON.parse(@response.body).key?("result")

    get get_transactions_url, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert JSON.parse(@response.body).key?("transactions")

    get remaining_free_transactions_url, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert JSON.parse(@response.body).key?("remaining_free_transactions")
    p @response.body
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
    post add_transaction_with_gas_credits_url, params: { id: user.id, tx_hash: "0x1234567890", gas_used: 100, status: "success", chain: "evm", data: "data" }, headers: { "Authorization" => "Bearer #{user.gen_auth_token}" }
    assert_response :success
    assert JSON.parse(@response.body).key?("result")
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


end
