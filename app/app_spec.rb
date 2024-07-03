# frozen_string_literal: true

require 'app'
require 'rack/test'

ENV['RACK_ENV'] = 'test'
ENV['VERBOSE'] = 'true'
ENV['WEBHOOK_SECRET'] = '4q72JHgX89z3BkFMt6cwQxL1rD28jpN5UfVhIZYPbCSeuGovRaWmA0sD9ECtX7Jf'
ENV['REDIS_URL'] = '0.0.0.0:6379'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.mock_with :rspec
end

describe App do
  let(:app) { App.new }
  context 'GET to /' do
    let(:response) { get '/' }

    it 'returns status 200 OK' do
      expect(response.status).to eq 200
    end
  end

  context 'Single POST to /webhook' do
    let(:response) do
      get '/reset'
      post '/webhook',
           { event_type: 'asset_value_created', occurred_at: '2020-03-04T09:15:00',
             content: { asset: { id: 4_079_332, href: 'https://api.netilion.endress.com/v1/assets/4079332' }, value: { key: 'level', group: 'measurement', unit: { id: 8594, href: 'https://api.netilion.endress.com/v1/units/8594' }, timestamp: '2020-03-04T08:38:25Z', value: '96.45' } } }.to_json,
           {
             'CONTENT_TYPE' => 'application/json',
             'HTTP_X_HUB_SIGNATURE_SHA256' => 'sha256=3195f5e8fe61286e95cd3db87e2b85d9c2a53d7ff3270e23de86310d74e4ae81'
           }
      get '/'
    end

    it 'returns status 200 OK' do
      expect(response.status).to eq 200
    end

    it 'should write to the database' do
      expect(JSON.parse(response.body)).to eq(
        'Asset:4079332' => {
          'time_sent' => '2020-03-04T09:15:00',
          'time_value' => '2020-03-04T08:38:25Z',
          'value' => '96.45'
        }
      )
    end
  end

  context 'Mutliple POST to /webhook' do
    let(:response_one) do
      get '/reset'
      post '/webhook',
           { event_type: 'asset_value_created', occurred_at: '2020-03-04T09:15:00',
             content: { asset: { id: 4_079_332, href: 'https://api.netilion.endress.com/v1/assets/4079332' }, value: { key: 'level', group: 'measurement', unit: { id: 8594, href: 'https://api.netilion.endress.com/v1/units/8594' }, timestamp: '2020-03-04T08:38:25Z', value: '96.45' } } }.to_json,
           {
             'CONTENT_TYPE' => 'application/json',
             'HTTP_X_HUB_SIGNATURE_SHA256' => 'sha256=3195f5e8fe61286e95cd3db87e2b85d9c2a53d7ff3270e23de86310d74e4ae81'
           }
    end

    let(:response_two) do
      post '/webhook',
           { event_type: 'asset_value_created', occurred_at: '1991-03-04T09:15:00',
             content: { asset: { id: 9002, href: 'https://api.netilion.endress.com/v1/assets/4079332' }, value: { key: 'level', group: 'measurement', unit: { id: 8594, href: 'https://api.netilion.endress.com/v1/units/8594' }, timestamp: '1991-03-04T08:38:25Z', value: '12.05' } } }.to_json,
           {
             'CONTENT_TYPE' => 'application/json',
             'HTTP_X_HUB_SIGNATURE_SHA256' => 'sha256=12099265014ffcd9be16f486b790e54608d151bff63e624e0ca53e6b75b4b7c8'
           }
      get '/'
    end

    it 'returns status 200 OK' do
      expect(response_one.status).to eq 200
      expect(response_two.status).to eq 200
    end

    it 'should write to the database.json file' do
      expect(JSON.parse(response_two.body)).to eq(
        'Asset:4079332' => {
          'time_sent' => '2020-03-04T09:15:00',
          'time_value' => '2020-03-04T08:38:25Z',
          'value' => '96.45'
        }, 'Asset:9002' => {
          'time_sent' => '1991-03-04T09:15:00',
          'time_value' => '1991-03-04T08:38:25Z',
          'value' => '12.05'
        }
      )
    end
  end
end
