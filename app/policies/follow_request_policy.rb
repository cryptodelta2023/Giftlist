# frozen_string_literal: true

module GiftListApp
  # Policy to determine if an account can view a particular giftlist
  class FollowRequestPolicy
    def initialize(giftlist, requestor_account, target_account, auth_scope = nil)
      @giftlist = giftlist
      @requestor_account = requestor_account
      @target_account = target_account
      @auth_scope = auth_scope
      @requestor = GiftlistPolicy.new(requestor_account, giftlist, auth_scope)
      @target = GiftlistPolicy.new(target_account, giftlist, auth_scope)
    end

    def can_invite?
      can_write? &&
        (@requestor.can_add_followers? && @target.can_follow?)
    end

    # shuan start
    def target_owner?
      @target.can_add_followers?
    end

    def target_follower?
      @giftlist.followers.include?(@target_account)
    end
    # end

    def can_remove?
      can_write? &&
        (@requestor.can_remove_followers? && target_is_follower?)
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('giftlists') : false
    end

    def target_is_follower?
      @giftlist.followers.include?(@target_account)
    end
  end
end
