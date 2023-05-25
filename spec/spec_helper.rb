# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  GiftListApp::Giftinfo.map(&:destroy)
  GiftListApp::Giftlist.map(&:destroy)
  GiftListApp::Account.map(&:destroy)
end

def auth_header(account_data)
  auth = GiftListApp::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )

  "Bearer #{auth[:attributes][:auth_token]}"
end

DATA = {
  accounts: YAML.load(File.read('app/db/seeds/accounts_seed.yml')),
  giftinfos: YAML.load(File.read('app/db/seeds/giftinfos_seed.yml')),
  giftlists: YAML.load(File.read('app/db/seeds/giftlists_seed.yml'))
}.freeze
