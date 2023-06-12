# frozen_string_literal: true

module GiftListApp
  # Service object to create a new giftlist for an owner
  class EditGiftlist
    # Error for owner cannot be follower
    class ForbiddenError < StandardError
      def message
        'You are not allowed to edit giftlists'
      end
    end

    def self.call(auth:, giftlist_data:, new_name:)
      policy = GiftlistPolicy.new(
        auth[:account], giftlist_data, auth[:scope]
      )
      raise ForbiddenError unless policy.can_edit?

      giftlist_data.list_name = new_name
      giftlist_data.save
    end
  end
end
