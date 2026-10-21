# frozen_string_literal: true

require "net/http"
require "uri"
require "json"

module KiriminAja
  module Http
    # Preserve RuntimeError compatibility while exposing diagnostic response data.
    class Error < RuntimeError
      attr_reader :status, :body

      def initialize(response)
        @status = response.code.to_i
        @body = response.body
        super("Request failed: #{response.code} #{response.message}")
      end
    end

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

        unless (200..299).cover?(response.code.to_i)
          raise Error.new(response)
        end

        JSON.parse(response.body)
      end

      def post_json(path, body = nil, **kwargs)
        body = kwargs unless kwargs.empty?
        request_json(path, method: "POST", body: body)
      end

      def get_json(path, query: nil)
        request_json(path, method: "GET", query: query)
      end

      def delete_json(path)
        request_json(path, method: "DELETE")
      end

      def put_json(path, body = nil, **kwargs)
        body = kwargs unless kwargs.empty?
        request_json(path, method: "PUT", body: body)
      end

      private

      def build_url(path, query)
        base = @config.resolved_base_url
        normalized_path = path.start_with?("/") ? path : "/#{path}"
        url = "#{base}#{normalized_path}"
        if query && !query.empty?
          params = URI.encode_www_form(query)
          url += "#{url.include?("?") ? "&" : "?"}#{params}"
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
                when "PUT"    then Net::HTTP::Put
                else raise ArgumentError, "Unsupported HTTP method: #{method}"
                end

        req = klass.new(uri)
        req["Accept"] = "application/json"
        req["Content-Type"] = "application/json"

        if body && !%w[GET DELETE].include?(method.upcase)
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
