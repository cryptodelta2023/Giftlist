# frozen_string_literal: true

require_relative './app'

module GiftListApp
  # Web controller for Giftkist API
  class Api < Roda
    route('giftinfos') do |routing|
      unless @auth_account
        routing.halt 403, { message: 'Not authorized' }.to_json
      end

      @info_route = "#{@api_root}/giftinfos"

      # GET api/v1/giftinfos/[info_id]
      routing.on String do |info_id|
        @req_giftinfo = Giftinfo.first(id: info_id)

        routing.get do
          giftinfo = GetGiftinfoQuery.call(
            auth: @auth, giftinfo: @req_giftinfo
          )

          { data: giftinfo }.to_json
        rescue GetGiftinfoQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetGiftinfoQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.warn "Giftinfo Error: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end