require 'cgi'
require 'json'

require 'rest_client'

require 'turbot/api/response'

module Turbot
  class API
    def initialize(params)
      @host = params[:host]
      @port = params[:port]
      @scheme = params[:scheme]
      @api_key = params[:api_key] || get_api_key_for_credentials(params[:username], params[:password])['api_key']
    end

    # @return [Hash] a hash with the user's details
    def get_user
      response = request(:get, '/api/user')

      # For backwards compatibility, this method must return a Hash, not a SuccessResponse.
      JSON.load(response.body)
    end

    # @return [String] the user's API key
    def get_api_key
      get_user['api_key']
    end

    # @return [Hash] a hash with a single key "api_key"
    def get_api_key_for_credentials(user, password)
      response = request(:get, '/api/user/api_key', {
        :email => user,
        :password => password,
      })

      # For backwards compatibility, this method must return a Hash, not a SuccessResponse.
      JSON.load(response.body)
    end

    # @return [Turbot::API::SuccessResponse, Turbot::API::FailureResponse]
    def list_bots
      request(:get, '/api/bots')
    end

    # @return [Turbot::API::SuccessResponse, Turbot::API::FailureResponse]
    def show_bot(bot_id)
      request(:get, "/api/bots/#{bot_id}")
    end

    # @return [Turbot::API::SuccessResponse, Turbot::API::FailureResponse]
    def create_bot(bot_id, config, env = nil)
      request(:post, '/api/bots', :bot => {:bot_id => bot_id, :config => config, :env => env})
    end

    # @return [Turbot::API::SuccessResponse, Turbot::API::FailureResponse]
    def update_bot(bot_id, config, env = nil)
      request(:put, "/api/bots/#{bot_id}", :bot => {:config => config, :env => env})
    end

    # @return [Turbot::API::SuccessResponse, Turbot::API::FailureResponse]
    def show_manifest(bot_id)
      request(:get, "/api/bots/#{bot_id}/manifest")
    end

    # @return [Turbot::API::SuccessResponse, Turbot::API::FailureResponse]
    def create_draft_data(bot_id, batch)
      request(:post, "/api/bots/#{bot_id}/draft_data", :batch => batch)
    end

    # @return [Turbot::API::SuccessResponse, Turbot::API::FailureResponse]
    def destroy_draft_data(bot_id)
      request(:delete, "/api/bots/#{bot_id}/draft_data")
    end

    # @return [Turbot::API::SuccessResponse, Turbot::API::FailureResponse]
    def update_code(bot_id, archive)
      request(:put, "/api/bots/#{bot_id}/code", {:archive => archive}, false)
    end

    # @return [Turbot::API::SuccessResponse, Turbot::API::FailureResponse]
    def start_run(bot_id)
      request(:post, "/api/bots/#{bot_id}/run/start")
    end

    # @return [Turbot::API::SuccessResponse, Turbot::API::FailureResponse]
    def stop_run(bot_id)
      request(:post, "/api/bots/#{bot_id}/run/stop")
    end

  private

    def build_url_and_params(path, params = {})
      url = URI::HTTP.build({
        :host => @host,
        :port => @port,
        :scheme => @scheme,
        :path => path.strip,
      }).to_s

      params[:api_key] = @api_key

      [url, params]
    end

    def request(method, path, params = {}, json = true)
      url, params = build_url_and_params(path, params)

      begin
        if method == :get || method == :delete
          response = RestClient.send(method, url, :params => params)
        elsif json == false
          response = RestClient.send(method, url, params)
        else
          response = RestClient.send(method, url, JSON.dump(params), :content_type => :json)
        end
        SuccessResponse.new(response)
      rescue RestClient::Exception => e
        FailureResponse.new(e.response)
      end
    end
  end
end
