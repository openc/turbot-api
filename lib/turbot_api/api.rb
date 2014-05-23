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
      response = RestClient.get(server_req("/users/get_user"))
      JSON.parse(response)
    end

    def get_api_key
      get_user["api_key"]
    end

    def get_api_key_for_credentials(user, password)
      url = server_req("/users/api_key",
        :email => user,
        :password => password)
      response = RestClient.get(url)
      JSON.parse(response)
    end

    def get_keys
      # return an array of ssh keys
      ["jkjk"]
    end

    def get_ssh_keys
      # return an array of ssh keys
      ["jkjk"]
    end

    def post_key(key)
      # receive ssh key and associate with account
    end

    def delete_key(key)
    end

    def delete_keys
    end

    def read_logs(bot, opts={})
      url = server_req("/users/read_logs", :bot => bot)
      JSON.parse(RestClient.get(url))
    end

    def post_bot(data)
      url = server_req("/users/post_bot")
      begin
        RestClient.post(url, data)
      rescue => e
        if e.response.match(/Gitlab::Error::NotFound/)
          puts "That bot already exists!"
          exit 0
        elsif e.response.match(/MissingManifest/)
          puts "ERROR: You didn't provide a manifest.json"
          exit 1
        else
          raise
        end
      end
      puts "Created bot #{data['bot_id']}"
    end

    def delete_bot(bot)
      RestClient.delete(server_req("/users/delete_bot", {:bot => bot}))
    end

    def get_bots
      JSON.parse(RestClient.get(server_req("/users/get_bots")).body)
    end

    def get_bot(bot)
      JSON.parse(RestClient.get(server_req("/users/get_bot", :bot => bot)).body)
    end

    def put_config_vars(bot, vars)
      JSON.parse(RestClient.post(server_req("/users/config_vars", :bot => bot, :vars => vars)).body)
    end

    def get_config_vars(bot)
      JSON.parse(RestClient.get(server_req("/users/config_vars", :bot => bot)).body)
    end

    def delete_config_var(bot, key)
      JSON.parse(RestClient.delete(server_req("/users/config_vars", :bot => bot, :key => key)).body)
    end

    def send_drafts_to_angler(bot, batch)
      RestClient.post(
        server_req("/users/send_drafts_to_angler"),
        {:bot => bot,
          :batch => batch}).body
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
  end
end
