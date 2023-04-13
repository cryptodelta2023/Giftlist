# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test GiftList Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:giftlists].each do |giftlist_data|
        GiftListApp::Giftlist.create(giftlist_data)
    end
  end

  it 'HAPPY: should be able to get list of all giftinfos' do
    proj = GiftListApp::Giftlist.first
    DATA[:giftinfos].each do |doc|
      proj.add_giftinfo(doc)
    end

    get "api/v1/giftlists/#{proj.id}/giftinfos"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single giftinfo' do
    doc_data = DATA[:giftinfos][1]
    proj = GiftListApp::Giftlist.first
    doc = proj.add_giftinfo(doc_data).save

    get "/api/v1/giftlists/#{proj.id}/giftinfos/#{doc.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal doc.id
    _(result['data']['attributes']['filename']).must_equal doc_data['filename']
  end

  it 'SAD: should return error if unknown giftinfo requested' do
    proj = GiftListApp::Giftlist.first
    get "/api/v1/giftlists/#{proj.id}/giftinfos/foobar"

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new giftinfos' do
    proj = GiftListApp::Giftlist.first
    doc_data = DATA[:giftinfos][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post "api/v1/giftlists/#{proj.id}/giftinfos",
         doc_data.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    doc = GiftListApp::Giftinfo.first

    _(created['id']).must_equal doc.id
    _(created['filename']).must_equal doc_data['filename']
    _(created['description']).must_equal doc_data['description']
  end
end