Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  root "home#index"
  post "send_sms" => "home#send_sms"
  post "send_email" => "home#send_email"
  post "signin" => "home#signin"
  post "signin_with_email" => "home#signin_with_email"
  post "signin_with_password" => "home#signin_with_password"
  post "set_handle" => "home#set_handle"
  post "set_image_url" => "home#set_image_url"
  get  "get_by_handle" => "home#get_by_handle"
  get  "get_user" => "home#get_user"
  get  "get_me" => "home#get_me"
  get  "remaining_free_transactions" => "home#remaining_free_transactions"
  get  "get_encrypted_keys" => "home#get_encrypted_keys"
  post "set_encrypted_keys" => "home#set_encrypted_keys"
  post "set_evm_chain_address" => "home#set_evm_chain_address"
  get  "get_transactions" => "home#get_transactions"
  post "add_transaction" => "home#add_transaction"
  post "add_transaction_with_gas_credits" => "home#add_transaction_with_gas_credits"
  get  "get_token_classes" => "home#get_token_classes"
  post "add_token_class" => "home#add_token_class"
  post "add_wallet" => "home#add_wallet"
  get  "get_wallets" => "home#get_wallets"
  post "remove_wallet" => "home#remove_wallet"
  post "set_contacts" => "home#set_contacts"
  get  "get_contacts" => "home#get_contacts"

  # Defines the root path route ("/")
end
