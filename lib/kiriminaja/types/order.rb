# frozen_string_literal: true

module KiriminAja
  module Types
    class RequestPickupItemMetadata
      attr_accessor :sku, :variant_label

      def initialize(sku: nil, variant_label: nil)
        @sku = sku
        @variant_label = variant_label
      end

      def to_h
        d = {}
        d[:sku] = @sku unless @sku.nil?
        d[:variant_label] = @variant_label unless @variant_label.nil?
        d
      end
    end

    class RequestPickupItem
      attr_accessor :name, :price, :qty, :weight, :width, :length, :height, :metadata

      def initialize(name:, price:, qty:, weight:,
                     width: nil, length: nil, height: nil, metadata: nil)
        @name = name
        @price = price
        @qty = qty
        @weight = weight
        @width = width
        @length = length
        @height = height
        @metadata = metadata
      end

      def to_h
        d = {
          name: @name,
          price: @price,
          qty: @qty,
          weight: @weight,
        }
        d[:width] = @width unless @width.nil?
        d[:length] = @length unless @length.nil?
        d[:height] = @height unless @height.nil?
        d[:metadata] = @metadata.to_h unless @metadata.nil?
        d
      end
    end

    class RequestPickupPackage
      attr_accessor :order_id, :destination_name, :destination_phone, :destination_address,
                    :destination_kecamatan_id, :weight, :width, :length, :height,
                    :item_value, :shipping_cost, :service, :service_type, :cod,
                    :package_type_id, :item_name,
                    :destination_kelurahan_id, :destination_zipcode, :qty,
                    :insurance_amount, :drop, :note, :items

      def initialize(order_id:, destination_name:, destination_phone:, destination_address:,
                     destination_kecamatan_id:, weight:, width:, length:, height:,
                     item_value:, shipping_cost:, service:, service_type:, cod:,
                     package_type_id:, item_name:,
                     destination_kelurahan_id: nil, destination_zipcode: nil, qty: nil,
                     insurance_amount: nil, drop: nil, note: nil, items: nil)
        @order_id = order_id
        @destination_name = destination_name
        @destination_phone = destination_phone
        @destination_address = destination_address
        @destination_kecamatan_id = destination_kecamatan_id
        @weight = weight
        @width = width
        @length = length
        @height = height
        @item_value = item_value
        @shipping_cost = shipping_cost
        @service = service
        @service_type = service_type
        @cod = cod
        @package_type_id = package_type_id
        @item_name = item_name
        @destination_kelurahan_id = destination_kelurahan_id
        @destination_zipcode = destination_zipcode
        @qty = qty
        @insurance_amount = insurance_amount
        @drop = drop
        @note = note
        @items = items
      end

      def to_h
        d = {
          order_id: @order_id,
          destination_name: @destination_name,
          destination_phone: @destination_phone,
          destination_address: @destination_address,
          destination_kecamatan_id: @destination_kecamatan_id,
          weight: @weight,
          width: @width,
          length: @length,
          height: @height,
          item_value: @item_value,
          shipping_cost: @shipping_cost,
          service: @service,
          service_type: @service_type,
          cod: @cod,
          package_type_id: @package_type_id,
          item_name: @item_name,
        }
        d[:destination_kelurahan_id] = @destination_kelurahan_id unless @destination_kelurahan_id.nil?
        d[:destination_zipcode] = @destination_zipcode unless @destination_zipcode.nil?
        d[:qty] = @qty unless @qty.nil?
        d[:insurance_amount] = @insurance_amount unless @insurance_amount.nil?
        d[:drop] = @drop unless @drop.nil?
        d[:note] = @note unless @note.nil?
        d[:items] = @items.map(&:to_h) unless @items.nil?
        d
      end
    end

    class RequestPickupPayload
      attr_accessor :address, :phone, :name, :kecamatan_id, :packages, :schedule,
                    :zipcode, :kelurahan_id, :latitude, :longitude, :platform_name

      def initialize(address:, phone:, name:, kecamatan_id:, packages:, schedule:,
                     zipcode: nil, kelurahan_id: nil, latitude: nil, longitude: nil, platform_name: nil)
        @address = address
        @phone = phone
        @name = name
        @kecamatan_id = kecamatan_id
        @packages = packages
        @schedule = schedule
        @zipcode = zipcode
        @kelurahan_id = kelurahan_id
        @latitude = latitude
        @longitude = longitude
        @platform_name = platform_name
      end

      def to_h
        d = {
          address: @address,
          phone: @phone,
          name: @name,
          kecamatan_id: @kecamatan_id,
          packages: @packages.map(&:to_h),
          schedule: @schedule,
        }
        d[:zipcode] = @zipcode unless @zipcode.nil?
        d[:kelurahan_id] = @kelurahan_id unless @kelurahan_id.nil?
        d[:latitude] = @latitude unless @latitude.nil?
        d[:longitude] = @longitude unless @longitude.nil?
        d[:platform_name] = @platform_name unless @platform_name.nil?
        d
      end
    end

    class InstantPickupItem
      attr_accessor :name, :description, :price, :weight

      def initialize(name:, description:, price:, weight:)
        @name = name
        @description = description
        @price = price
        @weight = weight
      end

      def to_h
        {
          name: @name,
          description: @description,
          price: @price,
          weight: @weight,
        }
      end
    end

    class InstantPickupPackage
      attr_accessor :origin_name, :origin_phone, :origin_lat, :origin_long,
                    :origin_address, :origin_address_note,
                    :destination_name, :destination_phone, :destination_lat, :destination_long,
                    :destination_address, :destination_address_note,
                    :shipping_price, :item

      def initialize(origin_name:, origin_phone:, origin_lat:, origin_long:,
                     origin_address:, origin_address_note:,
                     destination_name:, destination_phone:, destination_lat:, destination_long:,
                     destination_address:, destination_address_note:,
                     shipping_price:, item:)
        @origin_name = origin_name
        @origin_phone = origin_phone
        @origin_lat = origin_lat
        @origin_long = origin_long
        @origin_address = origin_address
        @origin_address_note = origin_address_note
        @destination_name = destination_name
        @destination_phone = destination_phone
        @destination_lat = destination_lat
        @destination_long = destination_long
        @destination_address = destination_address
        @destination_address_note = destination_address_note
        @shipping_price = shipping_price
        @item = item
      end

      def to_h
        {
          origin_name: @origin_name,
          origin_phone: @origin_phone,
          origin_lat: @origin_lat,
          origin_long: @origin_long,
          origin_address: @origin_address,
          origin_address_note: @origin_address_note,
          destination_name: @destination_name,
          destination_phone: @destination_phone,
          destination_lat: @destination_lat,
          destination_long: @destination_long,
          destination_address: @destination_address,
          destination_address_note: @destination_address_note,
          shipping_price: @shipping_price,
          item: @item.to_h,
        }
      end
    end

    class InstantPickupPayload
      attr_accessor :service, :service_type, :vehicle, :order_prefix, :packages

      def initialize(service:, service_type:, vehicle:, order_prefix:, packages:)
        @service = service
        @service_type = service_type
        @vehicle = vehicle
        @order_prefix = order_prefix
        @packages = packages
      end

      def to_h
        {
          service: @service.to_s,
          service_type: @service_type,
          vehicle: @vehicle.to_s,
          order_prefix: @order_prefix,
          packages: @packages.map(&:to_h),
        }
      end
    end
  end
end
