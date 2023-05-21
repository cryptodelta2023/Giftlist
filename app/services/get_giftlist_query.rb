# frozen_string_literal: true

module GiftListApp
  # Add a follower to another owner's existing giftlist
  class GetGiftlistQuery
    # Error for owner cannot be follower
    class ForbiddenError < StandardError
      def message
        'You are not allowed to access that giftlist'
      end
    end

    # Error for cannot find a giftlist
    class NotFoundError < StandardError
      def message
        'We could not find that giftlist'
      end
    end

    def self.call(account:, giftlist:)
      raise NotFoundError unless giftlist

      policy = GiftlistPolicy.new(account, giftlist)
      raise ForbiddenError unless policy.can_view?

      giftlist.full_details.merge(policies: policy.summary)
    end
  end
end
