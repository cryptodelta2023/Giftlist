# frozen_string_literal: true

module GiftListApp
  # Service object to create a new giftlist for an owner
  class DeleteGiftlist
    # Error for owner cannot be follower
    class ForbiddenError < StandardError
      def message
        'You are not allowed to delete the giftlist'
      end
    end

    def self.call(auth:, giftlist_data:)

      policy = GiftlistPolicy.new(
        auth[:account], giftlist_data, auth[:scope]
      )
      raise ForbiddenError unless policy.can_delete?
      giftlist_data.destroy
    end
  end
end
