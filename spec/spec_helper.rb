# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:giftlists].delete
  app.DB[:giftinfos].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:giftlists] = YAML.safe_load File.read('app/db/seeds/document_seeds.yml')
DATA[:giftinfos] = YAML.safe_load File.read('app/db/seeds/project_seeds.yml')