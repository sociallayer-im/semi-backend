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

end
