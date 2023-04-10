# frozen_string_literal: true

require 'roda'
require 'json'

module GiftList
  # Web controller for Credence API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'GiftListAPI up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'giftlists' do
          @list_route = "#{@api_root}/list/#{user_id}/giftlist" # 待改

          
          # GET api/v1/giftlists/[id]
          routing.get String do |uswid|
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

            if new_list.save
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
