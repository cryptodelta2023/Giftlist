# frozen_string_literal: true

module GiftListApp
  # Add a follower to another owner's existing giftlist
  class CreateGiftinfo
    # Error for owner cannot be follower
    class ForbiddenError < StandardError
      def message
        'You are not allowed to add more giftinfos'
      end
    end

    # Error for requests with illegal attributes
    class IllegalRequestError < StandardError
      def message
        'Cannot create a giftinfo with those attributes'
      end
    end

    def self.call(auth:, giftlist:, giftinfo_data:)
      policy = GiftlistPolicy.new(auth[:account], giftlist, auth[:scope])
      raise ForbiddenError unless policy.can_add_giftinfos?

      giftlist.add_giftinfo(giftinfo_data)
    rescue Sequel::MassAssignmentRestriction
      raise IllegalRequestError
    end
  end
end
