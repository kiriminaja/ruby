# frozen_string_literal: true

require_relative "api"

module KiriminAja
  module Config
    class ClientConfig
      attr_reader :env, :base_url, :api_key, :http_client

      def initialize(env: ENV_SANDBOX, api_key: nil, base_url: nil, http_client: nil)
        @env = env
        @api_key = api_key
        @base_url = base_url || KA_ENV_URL.fetch(env, KA_ENV_URL[ENV_SANDBOX])
        @http_client = http_client
      end

      def resolved_base_url
        @base_url.chomp("/")
      end
    end
  end
end
