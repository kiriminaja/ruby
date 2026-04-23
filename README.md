# KiriminAja Ruby SDK

[![Gem Version](https://img.shields.io/gem/v/kiriminaja)](https://rubygems.org/gems/kiriminaja)
[![license](https://img.shields.io/github/license/kiriminaja/ruby)](LICENSE)

Official Ruby SDK for the [KiriminAja](https://kiriminaja.com) logistics API. Zero external dependencies — uses only Ruby's standard library (`net/http`, `json`).

## Requirements

- Ruby 3.0+

## Installation

Add to your Gemfile:

```ruby
gem "kiriminaja"
```

Or install directly:

```bash
gem install kiriminaja
```

---

## Quick Start

Create a client with your API key, then call any service method.

```ruby
require "kiriminaja"

client = KiriminAja::Client.new(
  env: KiriminAja::Config::ENV_SANDBOX,  # or ENV_PRODUCTION
  api_key: ENV["KIRIMINAJA_API_KEY"],
)

# Use any service
provinces = client.address.provinces
```

---

## Config Options

| Option        | Type       | Default            | Description                            |
| ------------- | ---------- | ------------------ | -------------------------------------- |
| `env`         | `String`   | `ENV_SANDBOX`      | Target environment                     |
| `api_key`     | `String`   | —                  | Your KiriminAja API key                |
| `base_url`    | `String`   | Derived from `env` | Override the base URL                  |
| `http_client` | duck-typed | auto-created       | Custom HTTP client (proxy / test mock) |

```ruby
# Custom base URL
client = KiriminAja::Client.new(
  base_url: "https://tdev.kiriminaja.com",
  api_key: ENV["KIRIMINAJA_API_KEY"],
)

# Custom HTTP client (e.g. with a specific timeout)
require "net/http"

http = Net::HTTP.new("tdev.kiriminaja.com", 443)
http.use_ssl = true
http.open_timeout = 10
http.read_timeout = 10

client = KiriminAja::Client.new(
  api_key: "...",
  http_client: http,
)
```

---

## Services

### Address

```ruby
# List all provinces
client.address.provinces

# Cities in a province (provinsi_id)
client.address.cities(5)

# Districts in a city (kabupaten_id)
client.address.districts(12)

# Sub-districts in a district (kecamatan_id)
client.address.sub_districts(77)

# Search districts by name
client.address.districts_by_name("jakarta")
```

---

### Coverage Area & Pricing

```ruby
# Express shipping rates
client.coverage_area.pricing_express(
  KiriminAja::Types::PricingExpressPayload.new(
    origin: 1,
    destination: 2,
    weight: 1000,       # grams
    item_value: 50000,
    insurance: 0,
    courier: ["jne", "jnt"],
  )
)

# Instant (same-day) rates
client.coverage_area.pricing_instant(
  KiriminAja::Types::PricingInstantPayload.new(
    service: [KiriminAja::Types::InstantService::GOSEND],
    item_price: 10000,
    origin: KiriminAja::Types::PricingInstantLocationPayload.new(
      lat: -6.2, long: 106.8, address: "Jl. Sudirman No.1",
    ),
    destination: KiriminAja::Types::PricingInstantLocationPayload.new(
      lat: -6.21, long: 106.81, address: "Jl. Thamrin No.5",
    ),
    weight: 1000,
    vehicle: KiriminAja::Types::InstantVehicle::BIKE,
    timezone: "Asia/Jakarta",
  )
)
```

---

### Order — Express

```ruby
# Track by order ID
client.order.express.track("ORDER123")

# Cancel by AWB
client.order.express.cancel("AWB123456", "Customer request")

# Request pickup
client.order.express.request_pickup(
  KiriminAja::Types::RequestPickupPayload.new(
    address: "Jl. Jodipati No.29",
    phone: "08133345678",
    name: "Tokotries",
    kecamatan_id: 548,
    schedule: "2021-11-30 22:00:00",
    packages: [
      KiriminAja::Types::RequestPickupPackage.new(
        order_id: "YGL-000000019",
        destination_name: "Flag Test",
        destination_phone: "082223323333",
        destination_address: "Jl. Magelang KM 11",
        destination_kecamatan_id: 548,
        weight: 520,
        width: 8,
        length: 8,
        height: 8,
        item_value: 275000,
        shipping_cost: 65000,
        service: "jne",
        service_type: "REG23",
        cod: 0,
        package_type_id: 7,
        item_name: "TEST Item name",
        # `items` is optional. When provided, it lists the individual
        # items inside the package. `item_value` is still required.
        items: [
          KiriminAja::Types::RequestPickupItem.new(
            name: "Kaos Polos",
            price: 125000,
            qty: 2,
            weight: 260,
            width: 4,
            length: 4,
            height: 4,
            metadata: KiriminAja::Types::RequestPickupItemMetadata.new(
              sku: "KP-001",
              variant_label: "Merah / L",
            ),
          ),
        ],
      ),
    ],
  )
)
```

---

### Order — Instant

```ruby
# Create instant pickup
client.order.instant.create(
  KiriminAja::Types::InstantPickupPayload.new(
    service: KiriminAja::Types::InstantService::GOSEND,
    service_type: "instant",
    vehicle: KiriminAja::Types::InstantVehicle::BIKE,
    order_prefix: "BDI",
    packages: [
      KiriminAja::Types::InstantPickupPackage.new(
        origin_name: "Rizky",
        origin_phone: "081280045616",
        origin_lat: -7.854584,
        origin_long: 110.331154,
        origin_address: "Wirobrajan, Yogyakarta",
        origin_address_note: "Dekat Kantor",
        destination_name: "Okka",
        destination_phone: "081280045616",
        destination_lat: -7.776192,
        destination_long: 110.325053,
        destination_address: "Godean, Sleman",
        destination_address_note: "Dekat Pasar",
        shipping_price: 34000,
        item: KiriminAja::Types::InstantPickupItem.new(
          name: "Barang 1",
          description: "Barang 1 Description",
          price: 20000,
          weight: 1000,
        ),
      ),
    ],
  )
)

# Find a new driver for an existing order
client.order.instant.find_new_driver("ORDER123")

# Cancel instant order
client.order.instant.cancel("ORDER123")

# Track instant order
client.order.instant.track("ORDER123")
```

---

### Courier

```ruby
# List available couriers
client.courier.list

# Courier groups
client.courier.group

# Courier service detail
client.courier.detail("jne")

# Set whitelist services
client.courier.set_whitelist_services(["jne_reg", "jne_yes"])
```

---

### Credit

```ruby
# Get the current KiriminAja credit balance
client.credit.balance
```

---

### Utilities — Volumetric

Estimate the smallest bounding box (length / width / height) for a
multi-item package by trying three stacking strategies and returning the
arrangement with the smallest volume.

```ruby
dim = KiriminAja::Utils::Volumetric.calculate([
  { qty: 2, length: 10, width: 10, height: 2 },
  { qty: 1, length: 5,  width: 5,  height: 5 }
])
# dim[:length], dim[:width], dim[:height]
```

---

### Pickup Schedules

```ruby
client.pickup.schedules
```

---

### Payment

```ruby
client.payment.get_payment("PAY123")
```

---

## Rails Integration

The SDK works seamlessly in any Ruby application, including Rails.

### Initializer

```ruby
# config/initializers/kiriminaja.rb
KIRIMINAJA = KiriminAja::Client.new(
  env: KiriminAja::Config::ENV_PRODUCTION,
  api_key: Rails.application.credentials.kiriminaja_api_key,
)
```

### Controller usage

```ruby
class ShippingController < ApplicationController
  def rates
    result = KIRIMINAJA.coverage_area.pricing_express(
      KiriminAja::Types::PricingExpressPayload.new(
        origin: params[:origin].to_i,
        destination: params[:destination].to_i,
        weight: params[:weight].to_i,
        item_value: params[:item_value].to_i,
        insurance: 0,
        courier: params[:courier],
      )
    )
    render json: result
  end
end
```

---

## Contributing

For any requests, bugs, or comments, please open an [issue](https://github.com/kiriminaja/ruby/issues) or [submit a pull request](https://github.com/kiriminaja/ruby/pulls).

## Development

```bash
bundle install      # install dependencies
bundle exec rake    # run tests
```
