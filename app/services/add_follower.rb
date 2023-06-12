# frozen_string_literal: true

module GiftListApp
  # Add a follower to another owner's existing giftlist
  class AddFollower
    # Error for owner cannot be follower
    class ForbiddenError < StandardError
      def message
        # if @policy.owner?
        #   'You are not allowed to invite yourself as a follower'
        # elsif @policy.follower?
        #   'This follower is already on the list'
        # else
        #   'This email is not found'
        # end
        'You are not allowed to invite that person as a follower'
      end
    end

    # Error for owner cannot be follower
    class ForbiddenOwnerError < StandardError
      def message
        'You are not allowed to invite yourself as a follower'
      end
    end

    # Error for follower already on the list
    class ForbiddenFollowerError < StandardError
      def message
        'This follower is already on the following list'
      end
    end

    def self.call(auth:, giftlist:, follower_email:)
      invitee = Account.first(email: follower_email)
      policy = FollowRequestPolicy.new(
        giftlist, auth[:account], invitee, auth[:scope]
      )
      if !policy.owner?
        raise ForbiddenOwnerError
      elsif !policy.follower?
        raise ForbiddenFollowerError
      elsif !policy.can_invite?
        raise ForbiddenError
      end

      giftlist.add_follower(invitee)
      invitee
    end
  end
end
