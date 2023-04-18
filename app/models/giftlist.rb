# frozen_string_literal: true

require 'json'
require 'sequel'

module GiftListApp
  # Models a project
  class Giftlist < Sequel::Model
    one_to_many :giftinfos
    plugin :association_dependencies, giftinfos: :destroy
    plugin :uuid, field: :id

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :list_name, :list_owner

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
