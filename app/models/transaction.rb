class Transaction < ApplicationRecord
    belongs_to :user, optional: true
    belongs_to :wallet, optional: true
end
