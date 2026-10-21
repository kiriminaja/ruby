# frozen_string_literal: true

module KiriminAja
  module Services
    class ProfileService
      def initialize(http)
        @http = http
      end

      def get
        @http.get_json("/api/mitra/v6.2/profile")
      end

      # Return the profile object regardless of whether the API wraps it in
      # results, result, or data. `get` remains raw for backward compatibility.
      def normalized
        response = get
        unless response.is_a?(Hash)
          raise "Profile data is missing from the API response"
        end
        if response["status"] == false
          raise(response["text"] || response["message"] || "Failed to fetch profile")
        end

        %w[results result data].each do |key|
          return response[key] if response[key].is_a?(Hash)
        end
        return response if %w[id name email metadata].any? { |key| response.key?(key) }

        raise "Profile data is missing from the API response"
      end
    end
  end
end
