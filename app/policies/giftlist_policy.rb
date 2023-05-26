# frozen_string_literal: true

module GiftListApp
  # Policy to determine if an account can view a particular giftlist
  class GiftlistPolicy
    def initialize(account, giftlist)
      @account = account
      @giftlist = giftlist
    end

    def can_view?
      account_is_owner? || account_is_follower?
    end

    # duplication is ok!
    def can_edit?
      account_is_owner? || account_is_follower?
    end

    def can_delete?
      account_is_owner?
    end

    def can_leave?
      account_is_follower?
    end

    def can_add_giftinfos?
      account_is_owner? || account_is_follower?
    end

    def can_remove_giftinfos?
      account_is_owner?
    end

    def can_add_followers?
      account_is_owner?
    end

    def can_remove_followers?
      account_is_owner?
    end

    def can_follow?
      !(account_is_owner? or account_is_follower?)
    end

    def summary
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

    def account_is_owner?
      @giftlist.owner == @account
    end

    def account_is_follower?
      @giftlist.followers.include?(@account)
    end
  end
end
