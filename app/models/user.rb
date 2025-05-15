class User < ApplicationRecord
  before_create :set_tsid_id

  private

  def set_tsid_id
    self.id = Tsid::Generator.new.generate
  end
end