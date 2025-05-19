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
        response = SendSms.send_sms(phone, code)
        Rails.logger.info("SMS sent response: #{response}")
      rescue => e
        Rails.logger.error("Error sending SMS: #{e.message}")
      end
  end
    Rails.logger.info("phone: #{phone}, code: #{code}")
    render json: { result: "ok", code: code }
  end

  def signin
    phone = params[:phone]
    code = params[:code]
    token = VerificationToken.find_by(context: "phone-login", sent_to: phone, code: code, used: false)

    raise AppError.new("Invalid Phone Or Code") unless token
    raise AppError.new("Code Expired") if DateTime.now > token.expires_at

    token.update(used: true)

    user = User.find_or_create_by(phone: phone)
    render json: { result: "ok", auth_token: user.gen_auth_token, phone: params[:phone], id: user.id, address_type: "phone" }
  end

  def set_handle
    user = User.find_by(id: params[:id])
    raise AppError.new("User Not Found") unless user
    raise AppError.new("Invalid Auth Token") unless user == current_user

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

  def set_evm_chain_address
    user = User.find_by(id: params[:id])
    raise AppError.new("User Not Found") unless user
    raise AppError.new("Invalid Auth Token") unless user == current_user

    user.update(evm_chain_address: params[:evm_chain_address], evm_chain_active_key: params[:evm_chain_active_key])
    render json: { result: "ok" }
  end

  def set_encrypted_keys
    user = User.find_by(id: params[:id])
    raise AppError.new("User Not Found") unless user
    raise AppError.new("Invalid Auth Token") unless user == current_user

    user.update(encrypted_keys: params[:encrypted_keys], evm_chain_address: params[:evm_chain_address], evm_chain_active_key: params[:evm_chain_active_key])
    render json: { result: "ok" }
  end

  def get_encrypted_keys
    user = User.find_by(id: params[:id])
    raise AppError.new("User Not Found") unless user
    raise AppError.new("Invalid Auth Token") unless user == current_user

    render json: { result: "ok", encrypted_keys: user.encrypted_keys }
  end

  def get_user
    user = User.find_by(id: params[:id])
    raise AppError.new("User Not Found") unless user

    render json: user.as_json(only: [:id, :handle, :email, :phone, :image_url, :evm_chain_address, :evm_chain_active_key, :remaining_gas_credits, :total_used_gas_credits])
  end

  def get_me
    user = current_user
    raise AppError.new("User Not Found") unless user

    render json: user.as_json(only: [:id, :handle, :email, :phone, :image_url, :evm_chain_address, :evm_chain_active_key, :remaining_gas_credits, :total_used_gas_credits, :encrypted_keys])
  end

end
