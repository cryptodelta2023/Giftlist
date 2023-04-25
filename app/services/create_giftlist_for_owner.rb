# frozen_string_literal: true

module GiftListApp
  # Service object to create a new giftlist for an owner
  class CreateGiftlistForOwner
    def self.call(owner_id:, giftlist_data:)
      Account.find(id: owner_id)
             .add_owned_giftlists(giftlist_data)
    end
  end
end
