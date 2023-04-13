# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:giftinfos].delete
  app.DB[:giftlists].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:giftinfos] = YAML.safe_load File.read('app/db/seeds/giftinfo_seeds.yml')
DATA[:giftlists] = YAML.safe_load File.read('app/db/seeds/giftlist_seeds.yml')