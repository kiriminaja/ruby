# frozen_string_literal: true

module KiriminAja
  module Services
    class PickupService
      def initialize(http)
        @http = http
      end

      def schedules
        @http.post_json("/api/mitra/v2/schedules")
      end
    end
  end
end
