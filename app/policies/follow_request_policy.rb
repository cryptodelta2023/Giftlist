# frozen_string_literal: true

module GiftListApp
  # Policy to determine if an account can view a particular giftlist
  class FollowRequestPolicy
    def initialize(giftlist, requestor_account, target_account)
      @giftlist = giftlist
      @requestor_account = requestor_account
      @target_account = target_account
      @requestor = GiftlistPolicy.new(requestor_account, giftlist)
      @target = GiftlistPolicy.new(target_account, giftlist)
    end

    def can_invite?
      @requestor.can_add_followers? && @target.can_follow?
    end

    def can_remove?
      @requestor.can_remove_followers? && target_is_follower?
    end

    private

    def target_is_follower?
      @giftlist.followers.include?(@target_account)
    end
  end
end
