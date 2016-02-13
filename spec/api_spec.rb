require 'spec_helper'

RSpec.describe Turbot::API do
  let :api do
    Turbot::API.new(:host => 'example.com', :api_key => 'key')
  end

  let :api_without_key do
    Turbot::API.new(:host => 'example.com', :api_key => '')
  end

  describe '/api/user' do
    let :body do
      {
        'email' => 'email@example.com',
        'last_sign_in_at' => '2015-01-01T00:00:00.000Z',
        'api_key' => 'key',
        'bot_count' => 5,
      }
    end

    before do
      expect(RestClient).to receive(:get).
        with('http://example.com/api/user', :params => {:api_key => 'key'}).
        and_return(double(:body => JSON.dump(body)))
    end

    describe '#get_user' do
      it 'succeeds' do
        result = api.get_user
        expect(result).to be_a(Hash)
        expect(result).to eq(body)
      end
    end

    describe '#get_api_key' do
      it 'succeeds' do
        result = api.get_api_key
        expect(result).to be_a(String)
        expect(result).to eq('key')
      end
    end
  end

  describe '#get_api_key_for_credentials' do
    it 'succeeds' do
      body = {
        'api_key' => 'key'
      }

      expect(RestClient).to receive(:get).
        with('http://example.com/api/user/api_key', :params => {:email => 'email@example.com', :password => 'pass', :api_key => ''}).
        and_return(double(:body => JSON.dump(body)))

      result = api_without_key.get_api_key_for_credentials('email@example.com', 'pass')
      expect(result).to be_a(Hash)
      expect(result).to eq(body)
    end
  end

  describe '#list_bots' do
    it 'succeeds' do
      expect(RestClient).to receive(:get).
        with('http://example.com/api/bots', {:params => {:api_key => 'key'}}).
        and_return(double(:body => JSON.dump({})))

      api.list_bots
    end
  end

  describe '#show_bot' do
    it 'succeeds' do
      expect(RestClient).to receive(:get).
        with('http://example.com/api/bots/test-bot', {:params => {:api_key => 'key'}}).
        and_return(double(:body => JSON.dump({})))

      api.show_bot('test-bot')
    end
  end

  describe '#create_bot' do
    it 'succeeds' do
      expect(RestClient).to receive(:post).
        with('http://example.com/api/bots', JSON.dump(:bot => {:bot_id => 'test-bot', :config => {}, :env => nil}, :api_key => 'key'), :content_type => :json).
        and_return(double(:body => JSON.dump({})))

      api.create_bot('test-bot', {})
    end
  end

  describe '#update_bot' do
    it 'succeeds' do
      expect(RestClient).to receive(:put).
        with('http://example.com/api/bots/test-bot', JSON.dump(:bot => {:config => {}, :env => nil}, :api_key => 'key'), :content_type => :json).
        and_return(double(:body => JSON.dump({})))

      api.update_bot('test-bot', {})
    end
  end

  describe '#show_manifest' do
    it 'succeeds' do
      expect(RestClient).to receive(:get).
        with('http://example.com/api/bots/test-bot/manifest', {:params => {:api_key => 'key'}}).
        and_return(double(:body => JSON.dump({})))

      api.show_manifest('test-bot')
    end
  end

  describe '#create_draft_data' do
    it 'succeeds' do
      expect(RestClient).to receive(:post).
        with('http://example.com/api/bots/test-bot/draft_data', JSON.dump(:batch => {}, :api_key => 'key'), :content_type => :json).
        and_return(double(:body => JSON.dump({})))

      api.create_draft_data('test-bot', {})
    end
  end

  describe '#destroy_draft_data' do
    it 'succeeds' do
      expect(RestClient).to receive(:delete).
        with('http://example.com/api/bots/test-bot/draft_data', {:params => {:api_key => 'key'}}).
        and_return(double(:body => JSON.dump({})))

      api.destroy_draft_data('test-bot')
    end
  end

  describe '#update_code' do
    it 'succeeds' do
      data = {}
      body = JSON.dump({
        :data => data,
      })

      expect(RestClient).to receive(:put).
        with('http://example.com/api/bots/example/code', :api_key => 'key', :archive => 'binary').
        and_return(double(:body => body))

      result = api.update_code('example', 'binary')
      expect(result).to be_a(Turbot::API::SuccessResponse)
      expect(result.body).to eq(body)
      expect(result.message).to eq(nil)
      expect(result.data).to eq(data)
    end
  end

  describe '#start_run' do
    it 'succeeds' do
      expect(RestClient).to receive(:post).
        with('http://example.com/api/bots/test-bot/run/start', JSON.dump(:api_key => 'key'), :content_type => :json).
        and_return(double(:body => JSON.dump({})))

      api.start_run('test-bot')
    end
  end

  describe '#stop_run' do
    it 'succeeds' do
      expect(RestClient).to receive(:post).
        with('http://example.com/api/bots/test-bot/run/stop', JSON.dump(:api_key => 'key'), :content_type => :json).
        and_return(double(:body => JSON.dump({})))

      api.stop_run('test-bot')
    end
  end
end
