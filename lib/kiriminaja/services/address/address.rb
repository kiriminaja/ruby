# frozen_string_literal: true

module KiriminAja
  module Services
    class AddressService
      def initialize(http)
        @http = http
      end

      def provinces
        @http.post_json("/api/mitra/province")
      end

      def cities(provinsi_id)
        @http.post_json("/api/mitra/city", { provinsi_id: provinsi_id })
      end

      def districts(kabupaten_id)
        @http.post_json("/api/mitra/kecamatan", { kabupaten_id: kabupaten_id })
      end

      def sub_districts(kecamatan_id)
        @http.post_json("/api/mitra/kelurahan", { kecamatan_id: kecamatan_id })
      end

      def districts_by_name(search)
        @http.post_json("/api/mitra/v2/get_address_by_name", { search: search })
      end
    end
  end
end
