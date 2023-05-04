# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Giftinfo Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:giftlists].each do |giftlist_data|
      GiftListApp::Giftlist.create(giftlist_data)
    end
  end

  it 'HAPPY: should be able to get list of all giftinfos' do
    giftlist = GiftListApp::Giftlist.first
    DATA[:giftinfos].each do |info|
      giftlist.add_giftinfo(info)
    end

    get "api/v1/giftlists/#{giftlist.id}/giftinfos"
    _(last_response.status).must_equal 200

    result = JSON.parse(last_response.body)['data']
    _(result.count).must_equal 4
    result.each do |info|
      _(info['type']).must_equal 'giftinfo'
    end
  end

  it 'HAPPY: should be able to get details of a single giftinfo' do
    info_data = DATA[:giftinfos][1]
    giftlist = GiftListApp::Giftlist.first
    info = giftlist.add_giftinfo(info_data)

    get "/api/v1/giftlists/#{giftlist.id}/giftinfos/#{info.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['attributes']['id']).must_equal info.id
    _(result['attributes']['giftname']).must_equal info_data['giftname']
    _(result['attributes']['url']).must_equal info_data['url']
    _(result['attributes']['description']).must_equal info_data['description']
  end

  it 'SAD: should return error if unknown giftinfo requested' do
    giftlist = GiftListApp::Giftlist.first
    get "/api/v1/giftlists/#{giftlist.id}/giftinfos/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating Giftinfos' do
    before do
      @giftlist = GiftListApp::Giftlist.first
      @info_data = DATA[:giftinfos][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new giftinfos' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post "api/v1/giftlists/#{@giftlist.id}/giftinfos",
           @info_data.to_json, req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      info = GiftListApp::Giftinfo.first

      _(created['id']).must_equal info.id
      _(created['giftname']).must_equal @info_data['giftname']
      _(created['url']).must_equal @info_data['url']
      _(created['description']).must_equal @info_data['description']
    end

    it 'SECURITY: should not create giftinfos with mass assignment' do
      bad_data = @info_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/giftlists/#{@giftlist.id}/giftinfos",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
