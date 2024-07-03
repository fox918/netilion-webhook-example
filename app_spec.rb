require "app"
require "rack/test"

ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  config.mock_with :rspec
end

describe App do
  let(:app) { App.new }
  context "GET to /" do
    let(:response) { get "/" }

    it "returns status 200 OK" do
      expect(response.status).to eq 200
    end
  end

  context "POST to /webhook" do
    let(:response) {
      post "/webhook",
           { event_type: "asset_value_created", occurred_at: "2020-03-04T09:15:00", content: { asset: { id: 4079332, href: "https://api.netilion.endress.com/v1/assets/4079332" }, value: { key: "level", group: "measurement", unit: { id: 8594, href: "https://api.netilion.endress.com/v1/units/8594" }, timestamp: "2020-03-04T08:38:25Z", value: "96.45" } } }.to_json,
           { "CONTENT_TYPE" => "application/json", "X-Hub-Signature-Sha256" => "" }
    }

    it "returns status 200 OK" do
      expect(response.status).to eq 200
    end
  end
end
