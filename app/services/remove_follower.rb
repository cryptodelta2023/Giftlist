# frozen_string_literal: true

module GiftListApp
  # Add a follower to another owner's existing giftlist
  class RemoveFollower
    # Error for owner cannot be follower
    class ForbiddenError < StandardError
      def message
        'You are not allowed to remove that person'
      end
    end

    def self.call(auth:, follower_email:, giftlist_id:)
      giftlist = Giftlist.first(id: giftlist_id)
      follower = Account.first(email: follower_email)

      policy = FollowRequestPolicy.new(
        giftlist, auth[:account], follower, auth[:scope]
      )
      raise ForbiddenError unless policy.can_remove?

      giftlist.remove_follower(follower)
      follower
    end
  end
end
