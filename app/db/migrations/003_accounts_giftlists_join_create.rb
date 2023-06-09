# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_join_table(follower_id: :accounts, giftlist_id: :giftlists)
  end
end
