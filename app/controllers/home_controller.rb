class HomeController < ApplicationController
  def index
    render json: { message: "Hello, World!" }
  end

  def send_sms
    code = rand(100_000..999_999)
    phone = params[:phone]
    VerificationToken.create(context: "phone-login", sent_to: phone, code: code, expires_at: Time.now + 15.minutes)
    if ENV["SMS_ENABLED"] == "ENABLED"
      begin
        response = SendSms.send_sms_aliyun(phone, code)
        Rails.logger.info("SMS sent response: #{response}")
      rescue => e
        Rails.logger.error("Error sending SMS: #{e.message}")
      end
  end
    Rails.logger.info("phone: #{phone}, code: #{code}")
    render json: { result: "ok", code: code }
  end

  def send_email
    code = rand(100_000..999_999)
    email = params[:email]
    VerificationToken.create(context: "email-login", sent_to: email, code: code, expires_at: Time.now + 60.minutes)

    mailer = SigninMailer.with(code: code, recipient: email).signin
    mailer.deliver_now!

    render json: { result: "ok", email: params[:email] }
  end

  def signin
    phone = params[:phone]
    code = params[:code]
    token = VerificationToken.find_by(context: "phone-login", sent_to: phone, code: code, used: false)

    raise AppError.new("Invalid Phone Or Code") unless token
    raise AppError.new("Code Expired") if DateTime.now > token.expires_at

    token.update(used: true)

    user = User.find_or_create_by(phone: phone)
    user.update(phone_verified: true) if user.phone_verified == false
    render json: { result: "ok", auth_token: user.gen_auth_token, phone: params[:phone], id: user.id, address_type: "phone" }
  end

  def signin_with_email
    email = params[:email]
    code = params[:code]
    token = VerificationToken.find_by(context: "email-login", sent_to: email, code: code, used: false)

    raise AppError.new("Invalid Email Or Code") unless token
    raise AppError.new("Code Expired") if DateTime.now > token.expires_at

    token.update(used: true)

    user = User.find_or_create_by(email: email)
    render json: { result: "ok", auth_token: user.gen_auth_token, email: params[:email], id: user.id, address_type: "email" }
  end

  def signin_with_password
    phone = params[:phone]
    password = params[:password]
    user = User.find_by(phone: phone)
    if user
      if user.encrypted_password.present?
        raise AuthError.new("Invalid Phone Or Password") unless BCrypt::Password.new(user.encrypted_password) == password
      else
        user.update(encrypted_password: BCrypt::Password.create(password))
      end
      render json: { result: "ok", auth_token: user.gen_auth_token, phone: params[:phone], id: user.id, address_type: "phone" }
    else
      user = User.create(phone: phone, encrypted_password: BCrypt::Password.create(password))
      render json: { result: "ok", auth_token: user.gen_auth_token, phone: params[:phone], id: user.id, address_type: "phone" }
    end
  end

  def set_handle
    user = User.find_by(id: params[:id])
    raise AppError.new("User Not Found") unless user
    raise AppError.new("Invalid Auth Token") unless user == current_user
    raise AppError.new("handle can not be numeric") if params[:handle].match?(/\A\d+\z/)

    user.update(handle: params[:handle])
    render json: { result: "ok" }
  end

  def set_image_url
    user = User.find_by(id: params[:id])
    raise AppError.new("User Not Found") unless user
    raise AppError.new("Invalid Auth Token") unless user == current_user

    user.update(image_url: params[:image_url])
    render json: { result: "ok" }
  end

  def get_by_handle
    user = User.find_by(handle: params[:handle]) || User.find_by(phone: params[:handle])
    raise AppError.new("User Not Found") unless user
    render json: user.as_json(only: [:id, :handle, :phone, :image_url, :evm_chain_address, :evm_chain_active_key, :can_send_badge])
  end

  def get_user
    user = User.find_by(id: params[:id])
    raise AppError.new("User Not Found") unless user

    render json: user.as_json(only: [:id, :handle, :email, :phone, :image_url, :evm_chain_address, :evm_chain_active_key, :remaining_gas_credits, :total_used_gas_credits, :can_send_badge])
  end

  def get_me
    user = current_user
    raise AppError.new("User Not Found") unless user

    render json: user.as_json(only: [:id, :handle, :email, :phone, :image_url, :evm_chain_address, :evm_chain_active_key, :remaining_gas_credits, :total_used_gas_credits, :encrypted_keys, :can_send_badge])
  end

  def remaining_free_transactions
    user = current_user
    raise AppError.new("User Not Found") unless user

    render json: { result: "ok", remaining_free_transactions: (20 - user.transaction_count) }
  end

  def get_encrypted_keys
    user = User.find_by(id: params[:id])
    raise AppError.new("User Not Found") unless user
    raise AppError.new("Invalid Auth Token") unless user == current_user

    render json: { result: "ok", encrypted_keys: user.encrypted_keys }
  end

  def set_encrypted_keys
    user = User.find_by(id: params[:id])
    raise AppError.new("User Not Found") unless user
    raise AppError.new("Invalid Auth Token") unless user == current_user

    user.update(encrypted_keys: params[:encrypted_keys], evm_chain_address: params[:evm_chain_address], evm_chain_active_key: params[:evm_chain_active_key])
    render json: { result: "ok" }
  end

  def set_evm_chain_address
    user = User.find_by(id: params[:id])
    raise AppError.new("User Not Found") unless user
    raise AppError.new("Invalid Auth Token") unless user == current_user

    user.update(evm_chain_address: params[:evm_chain_address], evm_chain_active_key: params[:evm_chain_active_key])
    render json: { result: "ok" }
  end

  def get_transactions
    user = current_user
    raise AppError.new("User Not Found") unless user

    render json: { result: "ok", transactions: user.transactions.as_json(only: [:id, :tx_hash, :gas_used, :status, :chain, :data, :created_at]) }
  end

  def add_transaction
    user = current_user
    raise AppError.new("User Not Found") unless user

    transaction = user.transactions.create(tx_hash: params[:tx_hash], gas_used: params[:gas_used], status: params[:status], chain: params[:chain], data: params[:data])
    user.update(transaction_count: user.transaction_count + 1)
    render json: { result: "ok" }
  end

  def add_transaction_with_gas_credits
    # raise AppError.new("ADMIN ONLY") unless params[:ADMIN_KEY] == ENV["ADMIN_KEY"]
    # user = User.find_by(id: params[:id])
    user = current_user
    raise AppError.new("User Not Found") unless user

    transaction = user.transactions.create(tx_hash: params[:tx_hash], gas_used: params[:gas_used], status: params[:status], chain: params[:chain], data: params[:data])
    user.increment!(:total_used_gas_credits, params[:gas_used].to_i)
    user.update(transaction_count: user.transaction_count + 1)
    render json: { result: "ok" }
  end

  def get_token_classes
    render json: { result: "ok", token_classes: TokenClass.order(position: :desc).all }
  end

  def add_token_class
    user = current_user
    raise AppError.new("User Not Found") unless user
    TokenClass.create(
      token_type: params[:token_type], chain: params[:chain], chain_id: params[:chain_id], address: params[:address],
      name: params[:name], symbol: params[:symbol], decimals: params[:decimals], image_url: params[:image_url],
      publisher: user.id, publisher_address: params[:publisher_address], position: params[:position], description: params[:description])
    render json: { result: "ok" }
  end

  def add_wallet
    user = current_user
    raise AppError.new("User Not Found") unless user

    wallet = user.wallets.create(name: params[:name], wallet_type: params[:wallet_type], chain: params[:chain], evm_chain_address: params[:evm_chain_address], evm_chain_active_key: params[:evm_chain_active_key], encrypted_keys: params[:encrypted_keys], format: params[:format])
    render json: { result: "ok", wallet: wallet.as_json(only: [:id, :name, :wallet_type, :chain, :evm_chain_address, :evm_chain_active_key, :encrypted_keys, :format]) }
  end

  def get_wallets
    user = current_user
    raise AppError.new("User Not Found") unless user

    render json: { result: "ok", wallets: user.wallets.as_json(only: [:id, :name, :wallet_type, :chain, :evm_chain_address, :evm_chain_active_key, :encrypted_keys, :format]) }
  end

  def remove_wallet
    user = current_user
    raise AppError.new("User Not Found") unless user

    wallet = user.wallets.find_by(id: params[:id])
    raise AppError.new("Wallet Not Found") unless wallet

    wallet.destroy
    render json: { result: "ok" }
  end
end
