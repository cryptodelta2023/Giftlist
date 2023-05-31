# frozen_string_literal: true

require 'json'
require 'sequel'

module GiftListApp
  # Models a giftlist
  class Giftlist < Sequel::Model
    many_to_one :owner, class: :'GiftListApp::Account'

    many_to_many :followers,
                 class: :'GiftListApp::Account',
                 join_table: :accounts_giftlists,
                 left_key: :giftlist_id, right_key: :follower_id

    one_to_many :giftinfos

    plugin :association_dependencies,
           giftinfos: :destroy,
           followers: :nullify

    plugin :timestamps
    plugin :whitelist_security
    set_allowed_columns :list_name

    def to_h
      {
        type: 'giftlist',
        attributes: {
          id:,
          list_name:
        }
      }
    end

    def full_details
      to_h.merge(
        relationships: {
          owner:,
          followers:,
          giftinfos:
        }
      )
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
