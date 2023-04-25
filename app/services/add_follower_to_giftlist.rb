# frozen_string_literal: true

module GiftListApp
  # Add a collaborator to another owner's existing project
  class AddFollowerToGiftlist
    # Error for owner cannot be collaborator
    class OwnerNotFollowerError < StandardError
      def message = 'Owner cannot be follower of giftlist'
    end

    def self.call(email:, giftlist_id:)
      follower = Account.first(email:)
      giftlist = Giftlist.first(id: giftlist_id)
      raise(OwnerNotCollaboratorError) if giftlist.owner.id == follower.id

      giftlist.add_follower(follower)
    end
  end
end
