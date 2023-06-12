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

    def self.call(auth:, giftinfo_id:, giftlist_id:)
      giftlist = Giftlist.first(id: giftlist_id)
      giftinfo = Giftinfo.first(id: giftinfo_id)

      policy = GiftinfoRemovePolicy.new(
        giftlist, auth[:account], giftinfo, auth[:scope]
      )
      raise ForbiddenError unless policy.can_delete?

      giftinfo.delete
      giftinfo
    end
  end
end
