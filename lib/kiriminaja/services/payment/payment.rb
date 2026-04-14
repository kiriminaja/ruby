# frozen_string_literal: true

module KiriminAja
  module Services
    class PaymentService
      def initialize(http)
        @http = http
      end

      def get_payment(payment_id)
        @http.post_json("/api/mitra/v2/get_payment", { payment_id: payment_id })
      end
    end
  end
end
