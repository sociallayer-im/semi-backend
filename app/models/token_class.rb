class TokenClass < ApplicationRecord
    validates_inclusion_of :token_type, in: %w( ERC20 ERC721 ERC1155 ), on: :create, message: "token_type %s is not included in the list"
    validates_inclusion_of :chain, in: %w( ethereum optimism arbitrum moonbeam solana ), on: :create, message: "chain %s is not included in the list"
end
