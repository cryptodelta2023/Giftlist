# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Giftlist Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting giftlists' do
    it 'HAPPY: should be able to get list of all giftlists' do
      GiftListApp::Giftlist.create(DATA[:giftlists][0]).save
      GiftListApp::Giftlist.create(DATA[:giftlists][1]).save

      get 'api/v1/giftlists'
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['data'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single giftlist' do
      existing_list = DATA[:giftlists][1]
      GiftListApp::Giftlist.create(existing_list).save
      id = GiftListApp::Giftlist.first.id

      get "/api/v1/giftlists/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['attributes']['id']).must_equal id
      _(result['attributes']['list_name']).must_equal existing_list['list_name']
      _(result['attributes']['list_owner']).must_equal existing_list['list_owner']
    end

    it 'SAD: should return error if unknown giftlist requested' do
      get '/api/v1/giftlists/foobar'

      _(last_response.status).must_equal 404
    end
    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      GiftListApp::Giftlist.create(list_name: 'New Giftlist')
      GiftListApp::Giftlist.create(list_name: 'Newer Giftlist')
      get 'api/v1/projects/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Projects' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @giftlist_data = DATA[:giftlists][1]
    end

    it 'HAPPY: should be able to create new giftlists' do
      post 'api/v1/giftlists', @giftlist_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      giftlist = GiftListApp::Giftlist.first

      _(created['id']).must_equal giftlist.id
      _(created['list_name']).must_equal @giftlist_data['list_name']
      _(created['list_owner']).must_equal @giftlist_data['list_owner']
    end

    it 'SECURITY: should not create giftlist with mass assignment' do
      bad_data = @giftlist_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/giftlists', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
