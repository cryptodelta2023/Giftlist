# frozen_string_literal: true

require 'json'
require 'sequel'

module GiftListApp
  # Models a project
  class Giftlist < Sequel::Model
    many_to_one :owner, class: :'GiftListApp::Account'
    many_to_many :followers,
                 class: :'GiftListApp::Account',
                 join_table: :accounts_giftlists,
                 left_key: :giftlist_id, right_key: :follower_id

    one_to_many :giftinfos

    plugin :association_dependencies, giftinfos: :destroy, followers: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :list_name

    # rubocop:disable Metrics/MethodLength
    def to_json(options = {})
      JSON(
        {
          data: {
            type: 'giftlist',
            attributes: {
              id:,
              list_name:
            }
          }
        }, options
      )
    end
    # rubocop:enable Metrics/MethodLength
  end
end
