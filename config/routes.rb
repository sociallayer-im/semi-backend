Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  post "send_sms" => "home#send_sms"
  post "signin" => "home#signin"
  post "set_handle" => "home#set_handle"
  post "set_image_url" => "home#set_image_url"
  get  "get_user" => "home#get_user"
  get  "get_encrypted_keys" => "home#get_encrypted_keys"
  post "set_encrypted_keys" => "home#set_encrypted_keys"


  # Defines the root path route ("/")
  root "home#index"
end
