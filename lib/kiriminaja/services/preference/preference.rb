# frozen_string_literal: true

module KiriminAja
  module Services
    # Account-level preferences exposed by the PHP SDK's PreferenceRepository.
    class PreferenceService
      def initialize(http)
        @http = http
      end

      def set_whitelist_services(services)
        @http.post_json("/api/mitra/v3/set_whitelist_services", { services: services })
      end

      alias set_whitelist_expedition set_whitelist_services

      # Register the URL to which shipment callbacks are sent.
      def set_callback(url)
        @http.post_json("/api/mitra/set_callback", { url: url })
      end
    end
  end
end
