# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module KiriminAja
  module Http
    class Request
      def initialize(config)
        @config = config
      end

      def request_json(path, method: "POST", body: nil, query: nil, headers: nil)
        url = build_url(path, query)
        uri = URI.parse(url)

        http = @config.http_client || build_http(uri)
        req = build_request(uri, method, body, headers)

        response = http.request(req)

        unless response.is_a?(Net::HTTPSuccess)
          raise "Request failed: #{response.code} #{response.message}"
        end

        JSON.parse(response.body)
      end

      def post_json(path, body = nil)
        request_json(path, method: "POST", body: body)
      end

      def get_json(path)
        request_json(path, method: "GET")
      end

      def delete_json(path)
        request_json(path, method: "DELETE")
      end

      private

      def build_url(path, query)
        base = @config.resolved_base_url
        normalized_path = path.start_with?("/") ? path : "/#{path}"
        url = "#{base}#{normalized_path}"
        if query && !query.empty?
          params = URI.encode_www_form(query)
          url += "?#{params}"
        end
        url
      end

      def build_http(uri)
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = uri.scheme == "https"
        http
      end

      def build_request(uri, method, body, extra_headers)
        klass = case method.upcase
                when "GET"    then Net::HTTP::Get
                when "POST"   then Net::HTTP::Post
                when "DELETE" then Net::HTTP::Delete
                else raise ArgumentError, "Unsupported HTTP method: #{method}"
                end

        req = klass.new(uri)
        req["Accept"] = "application/json"

        if body && !%w[GET DELETE].include?(method.upcase)
          req["Content-Type"] = "application/json"
          req.body = JSON.generate(body)
        end

        if @config.api_key
          req["Authorization"] = "Bearer #{@config.api_key}"
        end

        if extra_headers
          extra_headers.each { |k, v| req[k] = v }
        end

        req
      end
    end
  end
end
