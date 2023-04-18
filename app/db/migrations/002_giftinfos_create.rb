# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:giftinfos) do
      primary_key :id
      foreign_key :giftlist_id, table: :giftlists

      String :giftname, null: false
      String :url, null: false, default: ''
      String :description_secure

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
