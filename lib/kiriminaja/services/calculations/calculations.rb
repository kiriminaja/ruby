# frozen_string_literal: true

module KiriminAja
  module Services
    class CalculationsService
      def initialize(http)
        @http = http
      end

      def cod(payload)
        @http.post_json("/api/mitra/calculations/cod", payload)
      end
    end
  end
end
