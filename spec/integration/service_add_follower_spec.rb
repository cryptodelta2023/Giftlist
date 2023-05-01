# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddFollowerToGiftlist service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      GiftListApp::Account.create(account_data)
    end

    giftlist_data = DATA[:giftlists].first

    @owner = GiftListApp::Account.all[0]
    @follower = GiftListApp::Account.all[1]
    @giftlist = GiftListApp::CreateGiftlistForOwner.call(
      owner_id: @owner.id, giftlist_data:
    )
  end

  it 'HAPPY: should be able to add a follower to a giftlist' do
    GiftListApp::AddFollowerToGiftlist.call(
      email: @follower.email,
      giftlist_id: @giftlist.id
    )

    _(@follower.giftlists.count).must_equal 1
    _(@follower.giftlists.first).must_equal @giftlist
  end

  it 'BAD: should not add owner as a follower' do
    _(proc {
      GiftListApp::AddFollowerToGiftlist.call(
        email: @owner.email,
        giftlist_id: @giftlist.id
      )
    }).must_raise GiftListApp::AddFollowerToGiftlist::OwnerNotFollowerError
  end
end
