# frozen_string_literal: true

module GiftListApp
  # Policy to determine if an account can view a particular giftlist
  class GiftinfoRemovePolicy
    def initialize(giftlist, requestor_account, target_giftinfo, auth_scope = nil)
      @giftlist = giftlist
      @requestor_account = requestor_account
      @target_giftinfo = target_giftinfo
      @auth_scope = auth_scope
      @requestor = GiftinfoPolicy.new(requestor_account, target_giftinfo, auth_scope)
    end

    def can_delete?
      can_write? && @requestor.can_delete?
    end

    private

    def can_write?
      @auth_scope ? @auth_scope.can_write?('giftlists') : false
    end
  end
end
