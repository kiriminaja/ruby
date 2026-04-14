# frozen_string_literal: true

module KiriminAja
  module Services
    class ExpressOrderService
      def initialize(http)
        @http = http
      end

      def track(order_id)
        @http.post_json("/api/mitra/tracking", { order_id: order_id })
      end

      def cancel(awb, reason)
        @http.request_json(
          "/api/mitra/v3/cancel_shipment",
          method: "POST",
          query: { "awb" => awb, "reason" => reason }
        )
      end

      def request_pickup(payload)
        @http.post_json("/api/mitra/v6.1/request_pickup", payload.to_h)
      end
    end

    class InstantOrderService
      def initialize(http)
        @http = http
      end

      def create(payload)
        @http.post_json("/api/mitra/v4/instant/pickup/request", payload.to_h)
      end

      def track(order_id)
        @http.get_json("/api/mitra/v4/instant/tracking/#{order_id}")
      end

      def cancel(order_id)
        @http.delete_json("/api/mitra/v4/instant/pickup/void/#{order_id}")
      end

      def find_new_driver(order_id)
        @http.post_json("/api/mitra/v4/instant/pickup/find-new-driver", { order_id: order_id })
      end
    end

    class OrderService
      attr_reader :express, :instant

      def initialize(http)
        @express = ExpressOrderService.new(http)
        @instant = InstantOrderService.new(http)
      end
    end
  end
end
