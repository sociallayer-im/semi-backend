class AuthToken < ApplicationRecord
  belongs_to :user, optional: true
  validates :token, presence: true, uniqueness: true
  before_validation :generate_token, on: :create

  def generate_token
    loop do
      self.token = SecureRandom.hex(16)
      break token unless AuthToken.exists?(token: self.token)
    end
  end
end