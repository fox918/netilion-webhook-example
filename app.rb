require "sinatra/base"
require 'dotenv/load'

class App < Sinatra::Base

  get '/' do
    content_type :json
    File.read('database.json') rescue {}
  end

  post '/webhook' do
    # Check if the request is signed and the signature is correct
    request.body.rewind
    hash = request.env['HTTP_X_HUB_SIGNATURE_SHA256']
    halt 403 if hash.nil?
    calculated_signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), ENV['WEBHOOK_SECRET'], request.body.read)}"

    if ENV['VERBOSE'] == 'true'
      puts "Calculated signature: #{calculated_signature}"
      puts "Received signature: #{hash}"
    end

    halt 403 unless Rack::Utils.secure_compare(calculated_signature, hash)

    # Parse the event (only continue if it is the event we expect
    request.body.rewind
    event = JSON.parse request.body.read
    halt 406 unless event['event_type'] == 'asset_value_created'

    # Save it to the json we use as database ;), this is not a good practice, but for this example it is ok
    asset_id = event['content']['asset']['id']
    event_parsed = {
      time_sent: event['occurred_at'],
      time_value: event['content']['value']['timestamp'],
      value: event['content']['value']['value']
    }

    database = JSON.parse(File.read('database.json')) rescue {}
    database[asset_id] = event_parsed
    File.write('database.json', JSON.pretty_generate(database))

    200
  end
end
