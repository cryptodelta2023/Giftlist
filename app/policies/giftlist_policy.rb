# frozen_string_literal: true

module GiftListApp
  # Policy to determine if an account can view a particular giftlist
  class GiftlistPolicy
    def initialize(account, giftlist, auth_scope = nil)
      @account = account
      @giftlist = giftlist
      @auth_scope = auth_scope
    end

    def can_view?
      can_read? && (account_is_owner? || account_is_follower?)
    end

    # duplication is ok!
    def can_edit?
      can_write? && account_is_owner?
    end

    def can_delete?
      can_write? && account_is_owner?
    end

    def can_leave?
      account_is_follower?
    end

    def can_add_giftinfos?
      can_write? && account_is_owner?
    end

    def can_remove_giftinfos?
      can_write? && account_is_owner?
    end

    def can_add_followers?
      can_write? && account_is_owner?
    end

    def can_remove_followers?
      account_is_owner?
    end

    def can_follow?
      !(account_is_owner? || account_is_follower?)
    end

    def summary # rubocop:disable Metrics/MethodLength
      {
        can_view: can_view?,
        can_edit: can_edit?,
        can_delete: can_delete?,
        can_leave: can_leave?,
        can_add_giftinfos: can_add_giftinfos?,
        can_delete_giftinfos: can_remove_giftinfos?,
        can_add_followers: can_add_followers?,
        can_remove_followers: can_remove_followers?,
        can_follow: can_follow?
      }
    end

    private

    def can_read?
      @auth_scope ? @auth_scope.can_read?('giftlists') : false
    end

    def can_write?
      @auth_scope ? @auth_scope.can_write?('giftlists') : false
    end

    def account_is_owner?
      @giftlist.owner == @account
    end

    def account_is_follower?
      @giftlist.followers.include?(@account)
    end
  end
end
