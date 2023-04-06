# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../app/controllers/app'
require_relative '../app/models/list_doc'

def app
  GiftList::Api
end

DATA = YAML.safe_load File.read('app/db/seeds/list_seeds.yml')

describe 'Test GiftList Web API' do
  include Rack::Test::Methods

  before do
    # Wipe database before each test
    Dir.glob("#{GiftList::STORE_DIR}/*.txt").each { |filename| FileUtils.rm(filename) }
  end

  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
  end

  describe 'Handle documents' do
    it 'HAPPY: should be able to get list of all gifts' do
        GiftList::List.new(DATA[0]).save
        GiftList::List.new(DATA[1]).save

      get 'api/v1/giftlists'
      result = JSON.parse last_response.body
      _(result['list_ids'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single gift' do
        GiftList::List.new(DATA[1]).save
      id = Dir.glob("#{GiftList::STORE_DIR}/*.txt").first.split(%r{[/.]})[3]

      get "/api/v1/giftlists/#{id}"
      result = JSON.parse last_response.body

      _(last_response.status).must_equal 200
      _(result['id']).must_equal id
    end

    it 'SAD: should return error if unknown gift requested' do
      get '/api/v1/giftlists/foobar'

      _(last_response.status).must_equal 404
    end

    it 'HAPPY: should be able to create new gift' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/giftlists', DATA[1].to_json, req_header

      _(last_response.status).must_equal 201
    end
  end
end