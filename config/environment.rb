# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

Rails.application.configure do
    config.action_mailer.delivery_method = :smtp
        config.action_mailer.smtp_settings = {
        :address   => 'smtp.resend.com',
        :port      => 465,
        :user_name => 'resend',
        :password  => ENV['RESEND_KEY'],
        :tls => true
    }
end
