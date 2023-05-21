# frozen_string_literal: true

module GiftListApp
  # Add a follower to another owner's existing giftlist
  class GetGiftinfoQuery
    # Error for owner cannot be follower
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that giftinfo'
      end
    end

    # Error for cannot find a giftlist
    class NotFoundError < StandardError
      def message
        'We could not find that giftinfo'
      end
    end

    # Giftinfo for given requestor account
    def self.call(requestor:, giftinfo:)
      raise NotFoundError unless giftinfo

      policy = GiftinfoPolicy.new(requestor, giftinfo)
      raise ForbiddenError unless policy.can_view?

      giftinfo
    end
  end
end
