class User < ApplicationRecord
  has_many :auth_tokens

  def gen_auth_token
    auth_token = AuthToken.create(user: self)
    auth_token.token
  end

  before_create :set_tsid_id

  private

  def set_tsid_id
    self.id = Tsid::Generator.new.generate
  end
end