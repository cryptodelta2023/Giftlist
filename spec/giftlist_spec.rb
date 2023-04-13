# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Giftlist Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all giftlists' do
    GiftListApp::Giftlist.create(DATA[:giftlists][0]).save
    GiftListApp::Giftlist.create(DATA[:giftlists][1]).save

    get 'api/v1/giftlists'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single giftlist' do
    existing_proj = DATA[:giftlists][1]
    GiftListApp::Giftlist.create(existing_proj).save
    id = GiftListApp::Giftlist.first.id

    get "/api/v1/giftlists/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['list_name']).must_equal existing_proj['list_name']
    _(result['data']['attributes']['list_owner']).must_equal existing_proj['list_owner']
  end

  it 'SAD: should return error if unknown giftlist requested' do
    get '/api/v1/giftlists/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new giftlists' do
    existing_proj = DATA[:giftlists][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/giftlists', existing_proj.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    proj = GiftListApp::Giftlist.first

    _(created['id']).must_equal proj.id
    _(created['list_name']).must_equal existing_proj['list_name']
    _(created['list_owner']).must_equal existing_proj['list_owner']
  end
end