# frozen_string_literal: true

require "minitest/autorun"
require "json"
require "net/http"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "kiriminaja"

# ---------------------------------------------------------------------------
# Recording HTTP stub — captures every request sent by the SDK
# ---------------------------------------------------------------------------

class RecordingHTTP
  Call = Struct.new(:method, :uri, :body, :headers, keyword_init: true)

  attr_reader :calls

  def initialize
    @calls = []
  end

  def request(req)
    @calls << Call.new(
      method: req.method,
      uri: req.uri || URI.parse(req.path),
      body: req.body,
      headers: req.each_header.to_h,
    )
    # Return a mock success response
    response = Net::HTTPOK.new("1.1", "200", "OK")
    response.instance_variable_set(:@body, '{"status":true}')
    response.instance_variable_set(:@read, true)
    response
  end
end

def make_client(env: KiriminAja::Config::ENV_SANDBOX, api_key: "test-key")
  http = RecordingHTTP.new
  client = KiriminAja::Client.new(env: env, api_key: api_key, http_client: http)
  [client, http]
end

# ---------------------------------------------------------------------------
# Config / env
# ---------------------------------------------------------------------------

class TestConfig < Minitest::Test
  def test_sandbox_base_url
    client, http = make_client(env: KiriminAja::Config::ENV_SANDBOX)
    client.address.provinces
    assert_includes http.calls[0].uri.to_s, "tdev.kiriminaja.com"
  end

  def test_production_base_url
    client, http = make_client(env: KiriminAja::Config::ENV_PRODUCTION)
    client.address.provinces
    assert_includes http.calls[0].uri.to_s, "client.kiriminaja.com"
  end

  def test_bearer_token
    client, http = make_client(api_key: "MY_KEY")
    client.address.provinces
    assert_equal "Bearer MY_KEY", http.calls[0].headers["authorization"]
  end
end

# ---------------------------------------------------------------------------
# Address service
# ---------------------------------------------------------------------------

class TestAddress < Minitest::Test
  def test_provinces
    client, http = make_client
    client.address.provinces
    assert_includes http.calls[0].uri.to_s, "/api/mitra/province"
    assert_equal "POST", http.calls[0].method
  end

  def test_cities
    client, http = make_client
    client.address.cities(5)
    assert_includes http.calls[0].uri.to_s, "/api/mitra/city"
    body = JSON.parse(http.calls[0].body)
    assert_equal({ "provinsi_id" => 5 }, body)
  end

  def test_districts
    client, http = make_client
    client.address.districts(12)
    assert_includes http.calls[0].uri.to_s, "/api/mitra/kecamatan"
    body = JSON.parse(http.calls[0].body)
    assert_equal({ "kabupaten_id" => 12 }, body)
  end

  def test_sub_districts
    client, http = make_client
    client.address.sub_districts(77)
    assert_includes http.calls[0].uri.to_s, "/api/mitra/kelurahan"
    body = JSON.parse(http.calls[0].body)
    assert_equal({ "kecamatan_id" => 77 }, body)
  end

  def test_districts_by_name
    client, http = make_client
    client.address.districts_by_name("jakarta")
    assert_includes http.calls[0].uri.to_s, "/api/mitra/v2/get_address_by_name"
    body = JSON.parse(http.calls[0].body)
    assert_equal({ "search" => "jakarta" }, body)
  end
end

# ---------------------------------------------------------------------------
# Coverage area + pricing
# ---------------------------------------------------------------------------

class TestCoverageArea < Minitest::Test
  def test_pricing_express
    client, http = make_client
    payload = KiriminAja::Types::PricingExpressPayload.new(
      origin: 1,
      destination: 2,
      weight: 1000,
      item_value: 50000,
      insurance: 0,
      courier: [KiriminAja::Types::ExpressService::JNE, "other"],
    )
    client.coverage_area.pricing_express(payload)
    assert_includes http.calls[0].uri.to_s, "/api/mitra/v6.1/shipping_price"
    assert_equal "POST", http.calls[0].method
    assert_equal "application/json", http.calls[0].headers["content-type"]
    body = JSON.parse(http.calls[0].body)
    assert_equal({ "origin" => 1, "destination" => 2, "weight" => 1000, "item_value" => 50000, "insurance" => 0, "courier" => ["jne", "other"] }, body)
  end

  def test_pricing_instant
    client, http = make_client
    payload = KiriminAja::Types::PricingInstantPayload.new(
      service: [KiriminAja::Types::InstantService::GOSEND, "other"],
      item_price: 10000,
      origin: KiriminAja::Types::PricingInstantLocationPayload.new(lat: -6.2, long: 106.8, address: "A"),
      destination: KiriminAja::Types::PricingInstantLocationPayload.new(lat: -6.21, long: 106.81, address: "B"),
      weight: 1000,
      vehicle: KiriminAja::Types::InstantVehicle::BIKE,
      timezone: "Asia/Jakarta",
    )
    client.coverage_area.pricing_instant(payload)
    assert_includes http.calls[0].uri.to_s, "/api/mitra/v4/instant/pricing"
    body = JSON.parse(http.calls[0].body)
    expected = JSON.parse(JSON.generate(payload.to_h))
    assert_equal expected, body
  end
end

# ---------------------------------------------------------------------------
# Order — Express
# ---------------------------------------------------------------------------

class TestOrderExpress < Minitest::Test
  def test_track
    client, http = make_client
    client.order.express.track("OID_EXP_1")
    assert_includes http.calls[0].uri.to_s, "/api/mitra/tracking"
    assert_equal "POST", http.calls[0].method
    body = JSON.parse(http.calls[0].body)
    assert_equal({ "order_id" => "OID_EXP_1" }, body)
  end

  def test_cancel
    client, http = make_client
    client.order.express.cancel("AWB123", "reason here")
    url = http.calls[0].uri.to_s
    assert_includes url, "/api/mitra/v3/cancel_shipment"
    assert_includes url, "awb=AWB123"
    assert_includes url, "reason=reason+here"
    assert_equal "POST", http.calls[0].method
  end

  def test_request_pickup
    client, http = make_client
    payload = KiriminAja::Types::RequestPickupPayload.new(
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
    client.order.express.request_pickup(payload)
    assert_includes http.calls[0].uri.to_s, "/api/mitra/v6.1/request_pickup"
    assert_equal "POST", http.calls[0].method
    body = JSON.parse(http.calls[0].body)
    assert_equal "Jl. Jodipati No.29", body["address"]
    assert_equal "YGL-000000019", body["packages"][0]["order_id"]
    assert_equal 1, body["packages"][0]["items"].length
    assert_equal "Kaos Polos", body["packages"][0]["items"][0]["name"]
    assert_equal "KP-001", body["packages"][0]["items"][0]["metadata"]["sku"]
  end
end

# ---------------------------------------------------------------------------
# Order — Instant
# ---------------------------------------------------------------------------

class TestOrderInstant < Minitest::Test
  def make_instant_payload
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
  end

  def test_create
    client, http = make_client
    payload = make_instant_payload
    client.order.instant.create(payload)
    assert_includes http.calls[0].uri.to_s, "/api/mitra/v4/instant/pickup/request"
    assert_equal "POST", http.calls[0].method
    body = JSON.parse(http.calls[0].body)
    assert_equal "gosend", body["service"]
    assert_equal "BDI", body["order_prefix"]
  end

  def test_track
    client, http = make_client
    client.order.instant.track("OID123")
    assert_includes http.calls[0].uri.to_s, "/api/mitra/v4/instant/tracking/OID123"
    assert_equal "GET", http.calls[0].method
  end

  def test_cancel
    client, http = make_client
    client.order.instant.cancel("OID123")
    assert_includes http.calls[0].uri.to_s, "/api/mitra/v4/instant/pickup/void/OID123"
    assert_equal "DELETE", http.calls[0].method
  end

  def test_find_new_driver
    client, http = make_client
    client.order.instant.find_new_driver("OID123")
    assert_includes http.calls[0].uri.to_s, "/api/mitra/v4/instant/pickup/find-new-driver"
    body = JSON.parse(http.calls[0].body)
    assert_equal({ "order_id" => "OID123" }, body)
  end
end

# ---------------------------------------------------------------------------
# Courier
# ---------------------------------------------------------------------------

class TestCourier < Minitest::Test
  def test_list
    client, http = make_client
    client.courier.list
    assert_includes http.calls[0].uri.to_s, "/api/mitra/couriers"
    assert_equal "POST", http.calls[0].method
  end

  def test_group
    client, http = make_client
    client.courier.group
    assert_includes http.calls[0].uri.to_s, "/api/mitra/couriers_group"
  end

  def test_detail
    client, http = make_client
    client.courier.detail("jne")
    body = JSON.parse(http.calls[0].body)
    assert_equal({ "courier_code" => "jne" }, body)
  end

  def test_set_whitelist_services
    client, http = make_client
    client.courier.set_whitelist_services(["jne_reg", "jne_yes"])
    assert_includes http.calls[0].uri.to_s, "/api/mitra/v3/set_whitelist_services"
    body = JSON.parse(http.calls[0].body)
    assert_equal({ "services" => ["jne_reg", "jne_yes"] }, body)
  end
end

# ---------------------------------------------------------------------------
# Credit
# ---------------------------------------------------------------------------

class TestCredit < Minitest::Test
  def test_balance
    client, http = make_client
    client.credit.balance
    assert_includes http.calls[0].uri.to_s, "/api/mitra/v6.2/credit/balance"
    assert_equal "GET", http.calls[0].method
  end
end

# ---------------------------------------------------------------------------
# Pickup
# ---------------------------------------------------------------------------

class TestPickup < Minitest::Test
  def test_schedules
    client, http = make_client
    client.pickup.schedules
    assert_includes http.calls[0].uri.to_s, "/api/mitra/v2/schedules"
    assert_equal "POST", http.calls[0].method
  end
end

# ---------------------------------------------------------------------------
# Payment
# ---------------------------------------------------------------------------

class TestPayment < Minitest::Test
  def test_get_payment
    client, http = make_client
    client.payment.get_payment("PAY123")
    assert_includes http.calls[0].uri.to_s, "/api/mitra/v2/get_payment"
    body = JSON.parse(http.calls[0].body)
    assert_equal({ "payment_id" => "PAY123" }, body)
  end
end
