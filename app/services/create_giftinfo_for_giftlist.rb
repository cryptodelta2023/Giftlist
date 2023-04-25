# frozen_string_literal: true

module GiftListApp
  # Create new configuration for a giftlist
  class CreateGiftinfoForGiftlist
    def self.call(giftlist_id:, giftinfo_data:)
      Giftlist.first(id: giftlist_id)
              .add_giftinfo(giftinfo_data)
    end
  end
end
