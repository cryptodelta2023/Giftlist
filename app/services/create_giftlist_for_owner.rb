# frozen_string_literal: true

module GiftListApp
    # Service object to create a new giftlist for an owner
    class CreateProjectForOwner
      def self.call(owner_id:, giftlist_data:)
        Account.find(id: owner_id)
               .add_owned_giftlist(giftlist_data)
      end
    end
  end
