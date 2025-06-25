class CreateTokenClasses < ActiveRecord::Migration[8.0]
  def change
    create_table :token_classes do |t|
      t.string :token_type, null: false, comment: "ERC20, ERC721, ERC1155"
      t.string :chain, null: false, comment: "ethereum, optimism, solana, etc"
      t.string :address, null: false, comment: "token address"
      t.string :name
      t.string :symbol
      t.string :image_url
      t.string :publisher
      t.string :publisher_address
      t.integer :position, default: 0
      t.text   :description

      t.timestamps
    end
  end
end
