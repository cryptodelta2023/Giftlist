# frozen_string_literal: true

module GiftListApp
  # Add a follower to another owner's existing giftlist
  class AddFollower
    # Error for owner cannot be follower
    class ForbiddenError < StandardError
      def message
        'You are not allowed to invite that person as followers'
      end
    end

    def self.call(auth:, giftlist:, follower_email:)
      invitee = Account.first(email: follower_email)
      policy = FollowRequestPolicy.new(
        giftlist, auth[:account], invitee, auth[:scope]
      )
      raise ForbiddenError unless policy.can_invite?

      giftlist.add_follower(invitee)
      invitee
    end
  end
end
