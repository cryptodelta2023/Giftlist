# frozen_string_literal: true

require 'json'
require 'sequel'

module GiftList
  # Models a secret document
  class GiftInfo < Sequel::Model
    many_to_one :giftlist

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'giftinfo',
            attributes: {
              info_id:,
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
