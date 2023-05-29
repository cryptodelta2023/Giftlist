# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test AddFollowers service' do
  before do
    wipe_database

    DATA[:accounts].each do |account_data|
      GiftListApp::Account.create(account_data)
    end

    giftlist_data = DATA[:giftlists].first

    @owner_data = DATA[:accounts][0]
    @owner = GiftListApp::Account.all[0]
    @follower = GiftListApp::Account.all[1]
    @giftlist = @owner.add_owned_giftlist(giftlist_data)
  end

  it 'HAPPY: should be able to add a follower to a giftlist' do
    auth = authorization(@owner_data)
    
    GiftListApp::AddFollower.call(
      auth:,
      giftlist: @giftlist,
      follower_email: @follower.email
    )

    _(@follower.giftlists.count).must_equal 1
    _(@follower.giftlists.first).must_equal @giftlist
  end

  it 'BAD: should not add owner as a follower' do
    auth = GiftListApp::AuthenticateAccount.call(
      username: @owner_data['username'],
      password: @owner_data['password']
    )
    _(proc {
      GiftListApp::AddFollower.call(
        auth:,
        giftlist: @giftlist,
        follower_email: @owner.email
      )
    }).must_raise GiftListApp::AddFollower::ForbiddenError
  end
end
