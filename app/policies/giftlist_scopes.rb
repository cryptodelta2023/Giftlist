# frozen_string_literal: true

module GiftListApp
  # Policy to determine if account can view a giftlist
  class GiftlistPolicy
    # Scope of giftlist policies
    class AccountScope
      def initialize(current_account, target_account = nil)
        target_account ||= current_account
        @full_scope = all_giftlists(target_account)
        @current_account = current_account
        @target_account = target_account
      end

      def viewable
        if @current_account == @target_account
          @full_scope
        else
          @full_scope.select do |giftlist|
            includes_follower?(giftlist, @current_account)
          end
        end
      end

      private

      def all_giftlists(account)
        account.owned_giftlists + account.followings
      end

      def includes_follower?(giftlist, account)
        giftlist.followers.include? account
      end
    end
  end
end
