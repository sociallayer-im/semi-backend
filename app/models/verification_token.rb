class VerificationToken < ApplicationRecord
  validates :context, :code, :sent_to, presence: true
end