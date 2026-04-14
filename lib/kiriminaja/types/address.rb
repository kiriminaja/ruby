# frozen_string_literal: true

module KiriminAja
  module Types
    class PricingExpressPayload
      attr_accessor :origin, :destination, :weight, :item_value, :insurance, :courier

      def initialize(origin:, destination:, weight:, item_value:, insurance:, courier:)
        @origin = origin
        @destination = destination
        @weight = weight
        @item_value = item_value
        @insurance = insurance
        @courier = courier
      end

      def to_h
        {
          origin: @origin,
          destination: @destination,
          weight: @weight,
          item_value: @item_value,
          insurance: @insurance,
          courier: @courier,
        }
      end
    end

    class PricingInstantLocationPayload
      attr_accessor :lat, :long, :address

      def initialize(lat:, long:, address:)
        @lat = lat
        @long = long
        @address = address
      end

      def to_h
        { lat: @lat, long: @long, address: @address }
      end
    end

    class PricingInstantPayload
      attr_accessor :service, :item_price, :origin, :destination, :weight, :vehicle, :timezone

      def initialize(service:, item_price:, origin:, destination:, weight:, vehicle:, timezone:)
        @service = service
        @item_price = item_price
        @origin = origin
        @destination = destination
        @weight = weight
        @vehicle = vehicle
        @timezone = timezone
      end

      def to_h
        {
          service: Array(@service),
          item_price: @item_price,
          origin: @origin.to_h,
          destination: @destination.to_h,
          weight: @weight,
          vehicle: @vehicle.to_s,
          timezone: @timezone,
        }
      end
    end
  end
end
