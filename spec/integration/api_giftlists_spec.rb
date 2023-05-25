# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Giftlist Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = GiftListApp::Account.create(@account_data)
    @wrong_account = GiftListApp::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting giftlists' do
    describe 'Getting list of giftlists' do
      before do
        @account.add_owned_giftlist(DATA[:giftlists][0])
        @account.add_owned_giftlist(DATA[:giftlists][1])
      end

      it 'HAPPY: should get list for authorized account' do
        header 'AUTHORIZATION', auth_header(@account_data)
        get 'api/v1/giftlists'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process without authorization' do
        get 'api/v1/giftlists'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single giftlist' do
      giftlist = @account.add_owned_giftlist(DATA[:giftlists][0])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "api/v1/giftlists/#{giftlist.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal giftlist.id
      _(result['attributes']['list_name']).must_equal giftlist.list_name
      # _(result['attributes']['list_name']).must_equal existing_list['list_name']
      # _(result['attributes']['list_owner']).must_equal existing_list['list_owner']
    end

    it 'SAD: should return error if unknown giftlist requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/giftlists/foobar'

      _(last_response.status).must_equal 404
    end

    it 'BAD AUTHORIZATION: should not get giftlist with wrong authorization' do
      giftlist = @account.add_owned_giftlist(DATA[:giftlists][0])

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/giftlists/#{giftlist.id}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['attributes']).must_be_nil
    end

    it 'BAD SQL VULNERABILTY: should prevent basic SQL injection of id' do
      @account.add_owned_giftlist(DATA[:giftlists][0])
      @account.add_owned_giftlist(DATA[:giftlists][1])

      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/giftlists/2%20or%20id%3E0'

      # deliberately not reporting detection -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Giftlists' do
    before do
      @giftlist_data = DATA[:giftlists][0]
    end

    it 'HAPPY: should be able to create new giftlists' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post '/api/v1/giftlists', @giftlist_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      giftlist = GiftListApp::Giftlist.first

      _(created['id']).must_equal giftlist.id
      _(created['list_name']).must_equal @giftlist_data['list_name']
      _(created['list_owner']).must_equal @giftlist_data['list_owner']
    end

    it 'SAD: should not create new giftlist without authorization' do
      post 'api/v1/giftlists', @giftlist_data.to_json

      created = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.headers['Location']).must_be_nil
      _(created).must_be_nil
    end

    it 'SECURITY: should not create giftlist with mass assignment' do
      bad_data = @giftlist_data.clone
      bad_data['created_at'] = '1900-01-01'
      header 'AUTHORIZATION', auth_header(@account_data)
      post '/api/v1/giftlists', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
