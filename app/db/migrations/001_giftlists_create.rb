# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:giftlists) do
      primary_key :id

      String :list_name, unique: true, null: false
      String :list_owner

      DateTime :created_at
      DateTime :updated_at
    end
  end
end
