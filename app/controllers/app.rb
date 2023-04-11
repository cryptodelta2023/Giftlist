# frozen_string_literal: true

require 'roda'
require 'json'

module GiftListApp
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
          @list_route = "#{@api_root}/giftlists"

          routing.on String do |list_id|
            routing.on 'giftinfos' do
              @info_route = "#{@api_root}/projects/#{list_id}/giftinfos"
              # GET api/v1/giftlists/[list_id]/giftinfos/[info_id]
              routing.get String do |info_id|
                info = GiftInfo.where(giftlist_id: list_id, id: info_id).first # giftlist_id:FK from giftlist
                info ? info.to_json : raise('Gift Information not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/giftlists/[list_id]/giftinfos
              routing.get do
                output = { data: GiftList.first(list_id:).giftinfos } # giftinfos 對應到 002_giftinfos_create.rb
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find gift informations'
              end

              # POST api/v1/giftlists/[ID]/giftinfos
              routing.post do
                new_data = JSON.parse(routing.body.read)
                giftlist = GiftList.first(list_id)
                new_info = giftlist.add_giftinfo(new_data)

                if new_info
                  response.status = 201
                  response['Location'] = "#{@info_route}/#{new_info.info_id}"
                  { message: 'Document saved', data: new_info }.to_json
                else
                  routing.halt 400, 'Could not save gift information'
                end

              rescue StandardError
                routing.halt 500, { message: 'Database error' }.to_json
              end
            end

            # GET api/v1/giftlists/[ID]
            routing.get do
              giftlist = GiftList.first(id: proj_id)
              giftlist ? giftlist.to_json : raise('Giftlist not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/giftlists
          routing.get do
            output = { data: GiftList.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find giftlist' }.to_json
          end

          # POST api/v1/giftlists
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_gistlist = GiftList.new(new_data)
            raise('Could not save giftlist') unless new_gistlist.save

            response.status = 201
            response['Location'] = "#{@list_route}/#{new_gistlist.list_id}"
            { message: 'Giftlist saved', data: new_gistlist }.to_json
          rescue StandardError => e
            routing.halt 400, { message: e.message }.to_json
          end
        end
      end
    end
  end
end
