# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:giftlists) do
      primary_key :id
      foreign_key :owner_id, :accounts

      String :list_name, unique: true, null: false
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
