# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl'

module GiftList
  STORE_DIR = 'app/db/store'

  # Holds a full secret document
  class List
    # Create a new document by passing in hash of attributes
    def initialize(new_list)
      @id          = new_list['id'] || new_id
      @giftname    = new_list['giftname']
      @type        = new_list['type']
      @description = new_list['description']
    end

    attr_reader :id, :giftname, :type, :description

    def to_json(options = {})
      JSON(
        {
          type: 'list',
          id:,
          giftname:,
          description:
        },
        options
      )
    end

    # File store must be setup once when application runs
    def self.setup
      Dir.mkdir(GiftList::STORE_DIR) unless Dir.exist? GiftList::STORE_DIR
    end

    # Stores document in file store
    def save
      File.write("#{GiftList::STORE_DIR}/#{id}.txt", to_json)
    end

    # Query method to find one document
    def self.find(find_id)
      list_file = File.read("#{GiftList::STORE_DIR}/#{find_id}.txt")
      List.new JSON.parse(list_file)
    end

    # Query method to retrieve index of all documents
    def self.all
      Dir.glob("#{GiftList::STORE_DIR}/*.txt").map do |file|
        file.match(%r{#{Regexp.quote(GiftList::STORE_DIR)}/(.*)\.txt})[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end
  end
end
