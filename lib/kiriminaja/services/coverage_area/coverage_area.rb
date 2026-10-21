# frozen_string_literal: true

module KiriminAja
  module Services
    class CoverageAreaService < AddressService
      def pricing_express(payload)
        @http.post_json("/api/mitra/v6.1/shipping_price", payload.to_h)
      end

      # Full express pricing uses the same API endpoint, but is kept as a
      # named operation to match the PHP SDK's public surface.
      def full_shipping_price(payload)
        pricing_express(payload)
      end

      def pricing_instant(payload)
        @http.post_json("/api/mitra/v4/instant/pricing", payload.to_h)
      end
    end
  end
end
