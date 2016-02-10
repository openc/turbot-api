module Turbot
  class API
    class Response < SimpleDelegator
      attr_reader :message

      def initialize(response)
        super
        @parsed_body = JSON.parse(response.body, :symbolize_names => true)
        @message = @parsed_body[:message]
      end
    end

    class SuccessResponse < Response
      attr_reader :data

      def initialize(response)
        super
        @data = @parsed_body[:data]
      end
    end

    class FailureResponse < Response
      attr_reader :error_code

      def initialize(response)
        super
        @error_code = @parsed_body[:error_code]
      end
    end
  end
end
