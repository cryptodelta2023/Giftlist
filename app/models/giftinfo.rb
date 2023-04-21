# frozen_string_literal: true

require 'json'
require 'sequel'

module GiftListApp
  # Models a secret document
  class Giftinfo < Sequel::Model
    many_to_one :giftlist

    plugin :uuid, field: :id
    plugin :timestamps, update_on_create: true
    plugin :whitelist_security
    set_allowed_columns :giftname, :url, :description

    # Secure getters and setters
    def description
      SecureDB.decrypt(description_secure)
    end

    def description=(plaintext)
      self.description_secure = SecureDB.encrypt(plaintext)
    end

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'giftinfo',
            attributes: {
              id:,
              giftname:,
              url:,
              description:
            }
          },
          included: {
            giftlist:
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
