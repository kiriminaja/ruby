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
    end
  end
end
