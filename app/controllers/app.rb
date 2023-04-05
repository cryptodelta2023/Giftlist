# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/list_doc'

module GiftList
  # Web controller for Credence API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      List.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'CredenceAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'giftlists' do
            # GET api/v1/giftlists/[id]
            routing.get String do |id|
              response.status = 200
              List.find(id).to_json

            rescue StandardError
              routing.halt 404, { message: 'Giftlist not found' }.to_json
            end

            # GET api/v1/giftlists
            routing.get do
              response.status = 200
              output = { list_ids: List.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/giftlists
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_list = List.new(new_data)

              if new_doc.save
                response.status = 201
                { message: 'Giftlist saved', id: new_list.id }.to_json
              else
                routing.halt 400, { message: 'Could not save giftlist' }.to_json
              end
            end
          end
        end
      end
    end
  end
end