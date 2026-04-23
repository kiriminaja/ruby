# frozen_string_literal: true

module KiriminAja
  module Services
    class CreditService
      def initialize(http)
        @http = http
      end

      def balance
        @http.get_json("/api/mitra/v6.2/credit/balance")
      end
    end
  end
end
