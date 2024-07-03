# frozen_string_literal: true

require 'sinatra/base'
require 'dotenv/load'
require 'redis'

class App < Sinatra::Base
  redis = Redis.new(url: ENV['REDIS_URL'])

  get '/' do
    content_type :json
    result = redis.scan_each(match: 'Asset:*').map do |key|
      [key, JSON.parse(redis.get(key))]
    end.to_h
    JSON.pretty_generate(result)
  end

  get '/reset' do
    redis.scan_each(match: 'Asset:*').map do |key|
      redis.del(key)
    end
    200
  end

  post '/webhook' do
    # Check if the request is signed and the signature is correct
    request.body.rewind
    hash = request.env['HTTP_X_HUB_SIGNATURE_SHA256']
    halt 403 if hash.nil?
    calculated_signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), ENV['WEBHOOK_SECRET'],
                                                             request.body.read)}"

    if ENV['VERBOSE'] == 'true'
      puts "Calculated signature: #{calculated_signature}"
      puts "Received signature: #{hash}"
    end

    halt 403 unless Rack::Utils.secure_compare(calculated_signature, hash)

    # Parse the event (only continue if it is the event we expect
    request.body.rewind
    event = JSON.parse request.body.read
    halt 406 unless event['event_type'] == 'asset_value_created'

    # We use redis as a makeshift database ;)
    asset_id = event['content']['asset']['id']
    key_id = event['content']['value']['key']
    event_parsed = {
      time_sent: event['occurred_at'],
      time_value: event['content']['value']['timestamp'],
      value: event['content']['value']['value']
    }

    redis.set("Asset:#{asset_id}:#{key_id}", event_parsed.to_json)
    200
  end
end
