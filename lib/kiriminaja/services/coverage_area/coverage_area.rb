# frozen_string_literal: true

module KiriminAja
  module Services
    class CoverageAreaService < AddressService
      def pricing_express(payload)
        @http.post_json("/api/mitra/v6.1/shipping_price", payload.to_h)
      end

      def pricing_instant(payload)
        @http.post_json("/api/mitra/v4/instant/pricing", payload.to_h)
      end
    end
  end
end
