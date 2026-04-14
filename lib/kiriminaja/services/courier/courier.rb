# frozen_string_literal: true

module KiriminAja
  module Services
    class CourierService
      def initialize(http)
        @http = http
      end

      def list
        @http.post_json("/api/mitra/couriers")
      end

      def group
        @http.post_json("/api/mitra/couriers_group")
      end

      def detail(courier_code)
        @http.post_json("/api/mitra/courier_services", { courier_code: courier_code })
      end

      def set_whitelist_services(services)
        @http.post_json("/api/mitra/v3/set_whitelist_services", { services: services })
      end
    end
  end
end
