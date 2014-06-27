require 'json'
require 'rest_client'

module Turbot
  class API
    def initialize(params)
      @headers = params[:headers]
      @host = params[:host]
      @port = params[:port]
      @username = params[:username]
      @password = params[:password]
      @scheme = params[:scheme]
      @ssl_verify_peer = params[:ssl_verify_peer]
      @api_key = params[:api_key] || get_api_key_for_credentials(@username, @password)["api_key"]
    end

    def get_user
      # TODO move away from using RestClient directly
      response = RestClient.get(server_req("/api/user"))
      JSON.parse(response)
    end

    def get_api_key
      get_user["api_key"]
    end

    def get_api_key_for_credentials(user, password)
      # TODO move away from using RestClient directly
      url = server_req("/api/user/api_key",
        :email => user,
        :password => password)
      response = RestClient.get(url)
      JSON.parse(response)
    end

    def list_bots
      request(:get, "/api/bots")
    end

    def show_bot(bot_id)
      request(:get, "/api/bots/#{bot_id}")
    end

    def create_bot(bot_id, config)
      request(:post, "/api/bots", :bot => {:bot_id => bot_id, :config => config})
    end

    def update_bot(bot_id, config)
      request(:put, "/api/bots/#{bot_id}", :bot => {:config => config})
    end

    def create_draft_data(bot_id, batch)
      request(:post, "/api/bots/#{bot_id}/draft_data", :batch => batch)
    end

    def destroy_draft_data(bot_id)
      request(:delete, "/api/bots/#{bot_id}/draft_data")
    end

    def update_code(bot_id, archive)
      # We can't use #request here since we're not sending JSON
      url = build_url("/api/bots/#{bot_id}/code")
      begin
        response = RestClient.put(url, :api_key => @api_key, :archive => archive)
        SuccessResponse.new(response)
      rescue RestClient::Exception => e
        FailureResponse.new(e.response)
      end
    end

    def start_run(bot_id)
      request(:post, "/api/bots/#{bot_id}/run/start")
    end

    def stop_run(bot_id)
      request(:post, "/api/bots/#{bot_id}/run/stop")
    end

    def get_ssh_keys
      []
    end

    def post_key(key)
    end

    private

    def server_req(path, params={})
      query_string = params.update(:api_key => @api_key).map do |k, v|
        "#{k}=#{v}" if v
      end.compact.join("&")
      args = {
        :host => @host,
        :port => @port,
        :scheme => @scheme,
        :path => path.strip
      }
      args[:query] = query_string unless query_string.empty?
      URI::HTTP.build(args).to_s
    end

    def request(method, path, params={})
      url = build_url(path)

      begin
        if method == :get || method == :delete
          response = RestClient.send(method, url, :params => params.merge(:api_key => @api_key))
        else
          response = RestClient.send(method, url, params.merge(:api_key => @api_key).to_json, :content_type => :json)
        end
        SuccessResponse.new(response)
      rescue RestClient::Exception => e
        FailureResponse.new(e.response)
      end
    end

    def build_url(path)
      args = {
        :host => @host,
        :port => @port,
        :scheme => @scheme,
        :path => path.strip
      }
      url = URI::HTTP.build(args).to_s
    end

    class SuccessResponse
      attr_reader :message, :data

      def initialize(response)
        data = JSON.parse(response.body, :symbolize_names => true)
        @message = data[:message]
        @data = data[:data]
      end
    end

    class FailureResponse
      attr_reader :message, :data

      def initialize(response)
        data = JSON.parse(response.body, :symbolize_names => true)
        @error_code = data[:error_code]
        @message = data[:message]
      end
    end
  end
end
