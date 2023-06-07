# frozen_string_literal: true

# Policy to determine if account can view a giftlist
class GiftinfoPolicy
  def initialize(account, giftinfo, auth_scope = nil)
    @account = account
    @giftinfo = giftinfo
    @auth_scope = auth_scope
  end

  def can_view?
    can_read? && (account_owns_giftlist? || account_is_giftlist_follower?)
  end

  def can_edit?
    can_write? && account_owns_giftlist?
  end

  def can_delete?
    can_write? && account_owns_giftlist?
  end

  def summary
    {
      can_view: can_view?,
      can_edit: can_edit?,
      can_delete: can_delete?
    }
  end

  private

  def can_read?
    @auth_scope ? @auth_scope.can_read?('giftinfos') : false
  end

  def can_write?
    @auth_scope ? @auth_scope.can_write?('giftinfos') : false
  end

  def account_owns_giftlist?
    @giftinfo.giftlist.owner == @account
  end

  def account_is_giftlist_follower?
    @giftinfo.giftlist.followers.include?(@account)
  end
end
