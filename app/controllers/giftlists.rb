# frozen_string_literal: true

require_relative './app'

module GiftListApp
  # Web controller for GiftListApp API
  class Api < Roda
    route('giftlists') do |routing|
      routing.halt(403, UNAUTH_MSG) unless @auth_account
      @list_route = "#{@api_root}/giftlists"
      routing.on String do |list_id|
        if list_id != 'myown' || list_id != 'following'
          @req_giftlist = Giftlist.first(id: list_id)
        end
        routing.is do
          # GET api/v1/giftlists/[list_id]
          routing.get do
            if list_id == 'myown'
              giftlists = GiftlistPolicy::AccountScope.new(@auth_account).own_giftlists(@auth_account)
              JSON.pretty_generate(data: giftlists)
            # rescue StandardError
            #   routing.halt 403, { message: 'Could not find any giftlists' }.to_json
            elsif list_id == 'following'
              giftlists = GiftlistPolicy::AccountScope.new(@auth_account).following_giftlists(@auth_account)
              JSON.pretty_generate(data: giftlists)
            # rescue StandardError
            #   routing.halt 403, { message: 'Could not find any giftlists' }.to_json
            else
              giftlist = GetGiftlistQuery.call(auth: @auth, giftlist: @req_giftlist)
              { data: giftlist }.to_json
            end
          rescue GetGiftlistQuery::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue GetGiftlistQuery::NotFoundError => e
            routing.halt 404, { message: e.message }.to_json
          rescue StandardError => e
            puts "FIND GIFTLIST ERROR: #{e.inspect}"
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # POST api/v1/giftlists/[list_id]

          routing.post do
            req_data = JSON.parse(routing.body.read)
            edit_giftinfo = EditGiftlist.call(
              auth: @auth,
              giftlist_data: @req_giftlist,
              new_name: req_data['new_list_name']
            )
            { message: 'Giftlist edited', data: edit_giftinfo }.to_json
          rescue GetGiftlistQuery::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue GetGiftlistQuery::NotFoundError => e
            routing.halt 404, { message: e.message }.to_json
          rescue StandardError => e
            puts "FIND GIFTLIST ERROR: #{e.inspect}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('giftinfos') do
          # POST api/v1/giftlists/[list_id]/giftinfos
          routing.post do
            new_giftinfo = CreateGiftinfo.call(
              auth: @auth,
              giftlist: @req_giftlist,
              giftinfo_data: JSON.parse(routing.body.read)
            )
            response.status = 201
            response['Location'] = "#{@info_route}/#{new_giftinfo.id}"
            { message: 'Giftinfo saved', data: new_giftinfo }.to_json
          rescue CreateGiftinfo::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateGiftinfo::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            Api.logger.warn "Could not create giftinfo: #{e.message}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
          # DELETE api/v1/giftlists/[list_id]/giftinfos
          routing.delete do
            req_data = JSON.parse(routing.body.read)
            giftinfo = RemoveGiftinfo.call(
              auth: @auth,
              giftinfo_id: req_data['giftinfo_id'],
              giftlist_id: list_id
            )

            { message: 'giftinfo removed from giftlist',
              data: giftinfo }.to_json
          rescue RemoveGiftinfo::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('followers') do
          # PUT api/v1/giftlists/[list_id]/followers
          routing.put do
            req_data = JSON.parse(routing.body.read)

            follower = AddFollower.call(
              auth: @auth,
              giftlist: @req_giftlist,
              follower_email: req_data['email']
            )

            { data: follower }.to_json
          rescue AddFollower::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # DELETE api/v1/giftlists/[list_id]/followers
          routing.delete do
            req_data = JSON.parse(routing.body.read)
            follower = RemoveFollower.call(
              auth: @auth,
              follower_email: req_data['email'],
              giftlist_id: list_id
            )

            { message: "#{follower.username} removed from giftlist",
              data: follower }.to_json
          rescue RemoveFollower::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end
      end

      routing.is do
        # GET api/v1/giftlists
        routing.get do
          giftlists = GiftlistPolicy::AccountScope.new(@auth_account).viewable
          JSON.pretty_generate(data: giftlists)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any giftlists' }.to_json
        end

        # POST api/v1/giftlists
        routing.post do
          new_data = JSON.parse(routing.body.read)
          new_giftlist = CreateGiftlistForOwner.call(
            auth: @auth, giftlist_data: new_data
          )

          response.status = 201
          response['Location'] = "#{@list_route}/#{new_giftlist.id}"
          { message: 'Giftlist saved', data: new_giftlist }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue CreateGiftlistForOwner::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError
          Api.logger.error "Unknown error: #{e.message}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
