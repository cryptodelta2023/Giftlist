# frozen_string_literal: true

require 'json'
require 'sequel'

module GiftListApp
  # Models a secret document
  class Giftinfo < Sequel::Model
    many_to_one :giftlist

    plugin :timestamps

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
