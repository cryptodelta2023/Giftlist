# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Giftinfos Handling' do
  before do
    wipe_database

    DATA[:giftlists].each do |giftlist_data|
      GiftListApp::Giftlist.create(giftlist_data)
    end
  end

  it 'HAPPY: should retrieve correct data from database' do
    info_data = DATA[:giftinfos][1]
    giftlist = GiftListApp::Giftlist.first
    new_info = giftlist.add_giftinfo(info_data)

    info = GiftListApp::Giftinfo.find(id: new_info.id)
    _(info.giftname).must_equal info_data['giftname']
    _(info.url).must_equal info_data['url']
    _(info.description).must_equal info_data['description']
  end

  it 'SECURITY: should not use deterministic integers' do
    info_data = DATA[:giftinfos][1]
    giftlist = GiftListApp::Giftlist.first
    new_info = giftlist.add_giftinfo(info_data)

    _(new_info.id.is_a?(Numeric)).must_equal false
  end

  it 'SECURITY: should secure sensitive attributes' do
    info_data = DATA[:giftinfos][1]
    giftlist = GiftListApp::Giftlist.first
    new_info = giftlist.add_giftinfo(info_data)
    stored_info = app.DB[:giftinfos].first

    _(stored_info[:description_secure]).wont_equal new_info.description # maybe change
  end
end
