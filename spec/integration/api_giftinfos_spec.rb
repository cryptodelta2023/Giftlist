# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Giftinfo Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = GiftListApp::Account.create(@account_data)
    @account.add_owned_giftlist(DATA[:giftlists][0])
    @account.add_owned_giftlist(DATA[:giftlists][1])
    GiftListApp::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting a single giftinfo' do
    it 'HAPPY: should be able to get details of a single giftinfo' do
      info_data = DATA[:giftinfos][0]
      giftlist = @account.giftlists.first
      info = giftlist.add_giftinfo(info_data)

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/giftinfos/#{info.id}"
      _(last_response.status).must_equal 200
      
      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal info.id
      _(result['attributes']['giftname']).must_equal info_data['giftname']
      _(result['attributes']['url']).must_equal info_data['url']
      _(result['attributes']['description']).must_equal info_data['description']
    end

    it 'SAD AUTHORIZATION: should not get details without authorization' do
      info_data = DATA[:giftinfos][1]
      giftlist = GiftListApp::Giftlist.first
      info = giftlist.add_giftinfo(info_data)

      get "/api/v1/giftinfos/#{info.id}"

      result = JSON.parse last_response.body
      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not get details with wrong authorization' do
      info_data = DATA[:giftinfos][0]
      giftlist = @account.giftlists.first
      info = giftlist.add_giftinfo(info_data)

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/giftinfos/#{info.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'SAD: should return error if unknown giftinfo does not exist' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/giftinfos/foobar'
      _(last_response.status).must_equal 404
    end

    describe 'Creating Giftinfos' do
      before do
        @giftlist = GiftListApp::Giftlist.first
        @info_data = DATA[:giftinfos][1]
      end

      it 'HAPPY: should be able to create when everything correct' do
        header 'AUTHORIZATION', auth_header(@account_data)
        post "api/v1/giftlists/#{@giftlist.id}/giftinfos", @info_data.to_json

        _(last_response.status).must_equal 201
        _(last_response.header['Location'].size).must_be :>, 0

        created = JSON.parse(last_response.body)['data']['attributes']
        info = GiftListApp::Giftinfo.first
        _(created['id']).must_equal info.id
        _(created['giftname']).must_equal @info_data['giftname']
        _(created['url']).must_equal @info_data['url']
        _(created['description']).must_equal @info_data['description']
      end

      it 'BAD AUTHORIZATION: should not create with incorrect authorization' do
        header 'AUTHORIZATION', auth_header(@wrong_account_data)
        post "api/v1/giftlists/#{@giftlist.id}/giftinfos", @info_data.to_json

        data = JSON.parse(last_response.body)['data']
        _(last_response.status).must_equal 403
        _(last_response.headers['Location']).must_be_nil
        _(data).must_be_nil
      end

      it 'SAD AUTHORIZATION: should not create without any authorization' do
        post "api/v1/giftlists/#{@giftlist.id}/giftinfos", @info_data.to_json

        data = JSON.parse(last_response.body)['data']

        _(last_response.status).must_equal 403
        _(last_response.headers['Location']).must_be_nil
        _(data).must_be_nil
      end

      it 'BAD VULNERABILITY: should not create with mass assignment' do
        bad_data = @info_data.clone
        bad_data['created_at'] = '1900-01-01'
        header 'AUTHORIZATION', auth_header(@account_data)
        post "api/v1/giftlists/#{@giftlist.id}/giftinfos", bad_data.to_json

        data = JSON.parse(last_response.body)['data']
        _(last_response.status).must_equal 400
        _(last_response.headers['Location']).must_be_nil
        _(data).must_be_nil
      end
    end
  end
end
