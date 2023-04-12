# frozen_string_literal: true

require 'json'
require 'sequel'

module GiftListApp
  # Models a project
  class GiftList < Sequel::Model
    one_to_many :giftinfos
    plugin :association_dependencies, giftinfos: :destroy

    plugin :timestamps

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'giftlist',
            attributes: {
              id:,
              list_name:,
              list_owner:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
