require 'turbot_api'

require "simplecov"
require "coveralls"
SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter "spec"
end

describe Turbot::API do
  before do
    @api = Turbot::API.new(:api_key => 'key', :host => 'example.com')
  end

  describe '#start_run' do
    it 'starts a run' do
      RestClient.should_receive(:post).
        with('http://example.com/api/bots/test-bot/run/start', :api_key => 'key').
        and_return(double(:body => {}.to_json))
      @api.start_run('test-bot')
    end
  end

  describe '#stop_run' do
    it 'stops a run' do
      RestClient.should_receive(:post).
        with('http://example.com/api/bots/test-bot/run/stop', :api_key => 'key').
        and_return(double(:body => {}.to_json))
      @api.stop_run('test-bot')
    end
  end
end
