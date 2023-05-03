# frozen_string_literal: true

require 'roda'
require_relative './app'

module GiftListApp
  # Web controller for GiftListApp API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('giftlists') do |routing|
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

            new_info = CreateGiftinfoForGiftlist.call(
              giftlist_id: list_id, giftinfo_data: new_data
            )

            response.status = 201
            response['Location'] = "#{@info_route}/#{new_info.id}"
            { message: 'Giftinfo saved', data: new_info }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.warn "MASS-ASSIGNMENT: #{e.message}"
            routing.halt 500, { message: 'Error creating giftinfo' }.to_json
          end
        end

        # GET api/v1/giftlists/[list_id]
        routing.get do
          list = Giftlist.first(id: list_id)
          list ? list.to_json : raise('Giftlist not found')
        rescue StandardError => e
          routing.halt 404, { message: e.message }.to_json
        end
      end

      # GET api/v1/giftlists
      routing.get do
        output = { data: Giftlist.all }
        JSON.pretty_generate(output)
      rescue StandardError
        routing.halt 404, { message: 'Could not find giftlists' }.to_json
      end

      # POST api/v1/giftlists
      routing.post do
        new_data = JSON.parse(routing.body.read)
        new_list = Giftlist.new(new_data)
        raise('Could not save giftlist') unless new_list.save

        response.status = 201
        response['Location'] = "#{@list_route}/#{new_list.id}"
        { message: 'Giftlist saved', data: new_list }.to_json
      rescue Sequel::MassAssignmentRestriction
        Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
        routing.halt 400, { message: 'Illegal Attributes' }.to_json
      rescue StandardError => e
        Api.logger.error "UNKOWN ERROR: #{e.message}"
        routing.halt 500, { message: 'Unknown server error' }.to_json
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
