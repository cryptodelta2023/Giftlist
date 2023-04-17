# frozen_string_literal: true

require 'roda'
require 'json'

module GiftListApp
  # Web controller for GiftListApp API
  class Api < Roda
    plugin :halt

    # rubocop:disable Metrics/BlockLength
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
              @info_route = "#{@api_root}/giftlists/#{list_id}/giftinfos"
              # GET api/v1/giftlists/[list_id]/giftinfos/[info_id]
              routing.get String do |info_id|
                info = Giftinfo.where(giftlist_id: list_id, id: info_id).first # giftlist_id:FK from giftlist
                info ? info.to_json : raise('Gift Information not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/giftlists/[list_id]/giftinfos
              routing.get do
                output = { data: Giftlist.first(id: list_id).giftinfos } # giftinfos 對應到 002_giftinfos_create.rb
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find gift informations'
              end

              # POST api/v1/giftlists/[list_id]/giftinfos
              routing.post do
                new_data = JSON.parse(routing.body.read)
                giftlist = Giftlist.first(id: list_id)
                new_info = giftlist.add_giftinfo(new_data)
                raise 'Could not save giftinfo' unless new_info

                response.status = 201
                response['Location'] = "#{@info_route}/#{new_info.id}"
                { message: 'Document saved', data: new_info }.to_json
              
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                routing.halt 400, {message: 'Illegal Attributes'}.to_json            

              rescue StandardError => e
                routing.halt 500, { message: e.message }.to_json
              end
            end

            # GET api/v1/giftlists/[list_id]
            routing.get do
              giftlist = Giftlist.first(id: list_id)
              giftlist ? giftlist.to_json : raise('Giftlist not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/giftlists
          routing.get do
            output = { data: Giftlist.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find giftlist' }.to_json
          end

          # POST api/v1/giftlists
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_giftlist = Giftlist.new(new_data)
            raise('Could not save giftlist') unless new_giftlist.save

            response.status = 201
            response['Location'] = "#{@list_route}/#{new_giftlist.id}"
            { message: 'Giftlist saved', data: new_giftlist }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.error "UNKNOWN ERROR: #{e.message}"
            routing.halt 400, { message: 'Unknown server error' }.to_json
          end
        end
      end
    end
  end
  # rubocop:disable Metrics/BlockLength
end
