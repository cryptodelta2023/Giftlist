# frozen_string_literal: true

module GiftListApp
  # Service object to create a new giftlist for an owner
  class CreateGiftlistForOwner
    # Error for owner cannot be collaborator
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more giftinfos'
      end
    end

    def self.call(auth:, giftlist_data:)
      raise ForbiddenError unless auth[:scope].can_write?('giftlists')

      auth[:account].add_owned_giftlist(giftlist_data)
    end
  end
end
