# frozen_string_literal: true

module GiftListApp
  # Add a follower to another owner's existing giftlist
  class RemoveGiftinfo
    # Error for owner cannot be follower
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that giftinfo'
      end
    end

    def self.call(req_username:, giftinfo_id:, giftlist_id:)
      account = Account.first(username: req_username)
      giftlist = Giftlist.first(id: giftlist_id)
      giftinfo = Giftinfo.first(id: giftinfo_id)

    #   policy = FollowRequestPolicy.new(giftlist, account, giftinfo)
    #   raise ForbiddenError unless policy.can_remove?

      giftlist.remove_giftinfo(giftinfo)
      giftinfo
    end
  end
end
