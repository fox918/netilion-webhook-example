require "sinatra/base"
require 'dotenv/load'

class App < Sinatra::Base

  get '/' do
    'Hello world!'
  end

  post '/webhook' do

    # Check if the request is signed and the signature is correct
    request.body.rewind
    puts request.env
    hash = request.env['HTTP_X_HUB_SIGNATURE_SHA256']
    puts "Request Hash: #{hash}"
    halt 403 if hash.nil?
    calculated_signature = "sha256=#{OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), ENV['WEBHOOK_SECRET'], request.body.read)}"
    puts "Calculated Hash: #{calculated_signature}"
    halt 403 unless Rack::Utils.secure_compare(calculated_signature, hash)

    # Parse the event
    request.body.rewind
    event = JSON.parse request.body.read

    # Save it to the json we use as database ;)
    200
  end
end
