# frozen_string_literal: true

require "minitest/autorun"
require_relative "../lib/kiriminaja"

class ParityHTTP
  Response = Struct.new(:code, :message, :body)
  attr_reader :requests

  def initialize(body = { "status" => true }, code: "200")
    @body, @code, @requests = body, code, []
  end

  def request(request)
    @requests << request
    Response.new(@code, "Test response", JSON.generate(@body))
  end
end

class TestPHPParity < Minitest::Test
  def client_for(body = { "status" => true }, options = {})
    http = ParityHTTP.new(body, **options)
    [KiriminAja::Client.new(http_client: http, api_key: "key"), http]
  end

  def test_preference_callback_and_whitelist
    client, http = client_for
    client.preference.set_callback("https://example.test/callback")
    client.preference.set_whitelist_expedition(["jne_reg"])
    client.courier.set_whitelist_services(["jne_reg"])
    assert_equal "/api/mitra/set_callback", http.requests[0].path
    assert_equal "POST", http.requests[0].method
    assert_equal({ "url" => "https://example.test/callback" }, JSON.parse(http.requests[0].body))
    assert_equal "/api/mitra/v3/set_whitelist_services", http.requests[1].path
    assert_equal http.requests[1].body, http.requests[2].body
  end

  def test_full_shipping_price
    client, http = client_for
    client.coverage_area.full_shipping_price(origin: 1, destination: 2, weight: 100)
    assert_equal "/api/mitra/v6.1/shipping_price", http.requests[0].path
    assert_equal({ "origin" => 1, "destination" => 2, "weight" => 100 }, JSON.parse(http.requests[0].body))
  end

  def test_profile_envelopes_and_raw_compatibility
    profile = { "id" => 1, "email" => "test@example.test" }
    %w[results result data].each do |key|
      body = { key => profile }
      client, http = client_for(body)
      assert_equal profile, client.profile.normalized
      assert_equal body, client.profile.get
      assert_equal "GET", http.requests[0].method
      assert_equal "/api/mitra/v6.2/profile", http.requests[0].path
    end
    client, = client_for(profile)
    assert_equal profile, client.profile.normalized
    client, = client_for("results" => {})
    assert_equal({}, client.profile.normalized)
  end

  def test_profile_failures
    [nil, {}, { "message" => "missing" }].each do |body|
      client, = client_for(body)
      assert_match(/Profile data is missing/, assert_raises(RuntimeError) { client.profile.normalized }.message)
    end
    client, = client_for("status" => false, "message" => "Denied", "results" => { "id" => 1 })
    assert_equal "Denied", assert_raises(RuntimeError) { client.profile.normalized }.message
  end

  def test_credit_envelopes_numeric_strings_and_raw_compatibility
    %w[results result data payload].each do |key|
      body = { key => { "balance" => "100.25" } }
      client, http = client_for(body)
      assert_equal 100.25, client.credit.amount
      assert_equal body, client.credit.balance
      assert_equal "GET", http.requests[0].method
      assert_equal "/api/mitra/v6.2/credit/balance", http.requests[0].path
    end
    [0, 10, -5, 10.5, "0", "+12", " 1.2e3 "].each do |value|
      client, = client_for("balance" => value)
      assert_equal Float(value), client.credit.amount
    end
    client, = client_for("results" => { "balance" => "invalid" }, "balance" => 42)
    assert_equal 42, client.credit.amount
  end

  def test_credit_failures
    [nil, {}, { "balance" => false }, { "balance" => "NaN" }].each do |body|
      client, = client_for(body)
      assert_match(/Credit balance is missing/, assert_raises(RuntimeError) { client.credit.amount }.message)
    end
    client, = client_for("status" => false, "text" => "Denied", "balance" => 50)
    assert_equal "Denied", assert_raises(RuntimeError) { client.credit.amount }.message
  end

  def test_transport_query_headers_put_and_response_errors
    http = ParityHTTP.new
    config = KiriminAja::Config::ClientConfig.new(base_url: "https://example.test/prefix/", api_key: "key", http_client: http)
    request = KiriminAja::Http::Request.new(config)
    request.request_json("endpoint?existing=1", query: { reason: "a & b" })
    req = http.requests[0]
    assert_equal "/prefix/endpoint?existing=1&reason=a+%26+b", req.path
    assert_equal "Bearer key", req["Authorization"]
    assert_equal "application/json", req["Accept"]
    assert_equal "application/json", req["Content-Type"]
    assert_nil req.body
    request.put_json("endpoint", { enabled: false })
    assert_equal "PUT", http.requests[1].method
    assert_equal({ "enabled" => false }, JSON.parse(http.requests[1].body))
    request.get_json("endpoint", query: { id: 1 })
    assert_equal "/prefix/endpoint?id=1", http.requests[2].path
    assert_nil http.requests[2].body
    client, = client_for({ "message" => "Denied" }, code: "401")
    error = assert_raises(KiriminAja::Http::Error) { client.profile.get }
    assert_kind_of RuntimeError, error
    assert_equal 401, error.status
    assert_equal({ "message" => "Denied" }, JSON.parse(error.body))
  end

  def test_awb_and_cod_routes
    client, http = client_for
    client.awb.print(awb: ["AWB"])
    client.calculations.cod(item_price: 1000, data: [])
    assert_equal "/api/mitra/v6.1/awb/print", http.requests[0].path
    assert_equal({ "awb" => ["AWB"] }, JSON.parse(http.requests[0].body))
    assert_equal "/api/mitra/calculations/cod", http.requests[1].path
    assert_equal "POST", http.requests[1].method
  end
end
