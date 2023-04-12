# frozon_string_literal: true

require 'sequel'

Sequel.migration do
    change do
        create_table(:giftinfos) do
            primary_key :id
            foreign_key :giftlist_id, table :giftllists

            String :giftname, unique: true, null: false
            String :url, null:false
            String :description

            DateTime :created_at
            DateTime :updated_at

        end
    end
end