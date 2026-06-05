# frozen_string_literal: true

module KiriminAja
  module Services
    class AWBService
      def initialize(http)
        @http = http
      end

      def print(payload)
        @http.post_json("/api/mitra/v6.1/awb/print", payload)
      end
    end
  end
end
