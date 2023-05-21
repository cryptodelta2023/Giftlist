# frozen_string_literal: true

# Policy to determine if account can view a giftlist
class GiftinfoPolicy
  def initialize(account, giftinfo)
    @account = account
    @giftinfo = giftinfo
  end

  def can_view?
    account_owns_giftlist? || account_followers_on_giftlist?
  end

  def can_edit?
    account_owns_giftlist? || account_followers_on_giftlist?
  end

  def can_delete?
    account_owns_giftlist? || account_followers_on_giftlist?
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def account_owns_giftlist?
    @giftinfo.giftlist.owner == @account
  end

  def account_followers_on_giftlist?
    @giftinfo.giftlist.followers.include?(@account)
  end
end
