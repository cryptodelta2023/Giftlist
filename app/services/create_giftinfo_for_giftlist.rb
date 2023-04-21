# frozen_string_literal: true

module GiftListApp
    # Create new configuration for a giftlist
    class CreateGiftinfoForGiftlist
      def self.call(giftlist_id:, document_data:)
        Giftlist.first(id: giftlist_id)
               .add_document(document_data)
      end
    end
  end
