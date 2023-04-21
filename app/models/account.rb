# frozen_string_literal: true

require 'sequel'
require 'json'
require_relative './password'

module GiftListApp
  # Models a registered account
  class Account < Sequel::Model
    one_to_many :owned_giftlists, class: :'GiftListApp::Giftlist', key: :owner_id


    many_to_many :collaborations,
                 class: :'GiftListApp::Giftlist',
                 join_table: :accounts_giftlists,
                 left_key: :collaborator_id, right_key: :giftlist_id

    plugin :association_dependencies,
        owned_giftlists: :destroy,
        collaborations: :nullify

    plugin :whitelist_security
    set_allowed_columns :username, :email, :password

    plugin :timestamps, update_on_create: true

    def giftlists
      owned_giftlists + collaborations
    end

    def password=(new_password)
      self.password_digest = Password.digest(new_password)
    end

    def password?(try_password)
      digest = GiftListApp::Password.from_digest(password_digest)
      digest.correct?(try_password)
    end

    def to_json(options = {})
      JSON(
        {
          type: 'account',
          id:,
          username:,
          email:
        }, options
      )
    end
  end
end
