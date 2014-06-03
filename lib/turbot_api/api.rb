require 'action_dispatch'
require 'debugger'
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

      @routes = ActionDispatch::Routing::RouteSet.new

      @routes.draw do
        namespace :api do
          resources :bots, :only => [:index, :create] do
            resource :code, :only => [:update], :controller => 'code'
            resource :draft_data, :only => [:update]
          end

          resource :user, :only => [:show] do
            resource :api_key, :only => [:show]
          end
        end
      end

      @routes.default_url_options[:host] = @host
      @routes.default_url_options[:port] = @port
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
      request(:get, :bots)
    end

    def show_bot(bot_id)
      request(:get, :bot, :bot_id => bot_id)
    end

    def create_bot(bot_id, config)
      request(:post, :bots, :bot => {:bot_id => bot_id, :config => config})
    end

    def update_draft_data(bot_id, config, batch)
      request(:put, :bot_draft_data, :bot_id => bot_id, :config => config, :batch => batch)
    end

    def update_code(bot_id, archive)
      request(:put, :bot_code, :bot_id => bot_id, :archive => archive)
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

    def request(method, named_route, params={})
      begin
        url = @routes.url_helpers.send("api_#{named_route}_url")
      rescue ActionController::UrlGenerationError
        url = @routes.url_helpers.send("api_#{named_route}_url", :bot_id => params[:bot_id])
      end

      begin
        if method == :get
          response = RestClient.send(method, url, :params => params.merge(:api_key => @api_key))
        else
          response = RestClient.send(method, url, params.merge(:api_key => @api_key))
        end
        SuccessResponse.new(response)
      rescue RestClient::Exception => e
        FailureResponse.new(e.response)
      end
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
