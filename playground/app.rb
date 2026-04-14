# frozen_string_literal: true

require "sinatra"
require "json"
require "kiriminaja"

# ---------------------------------------------------------------------------
# Initialise the SDK once at boot (reads API key from ENV)
# ---------------------------------------------------------------------------

CLIENT = KiriminAja::Client.new(
  env: KiriminAja::Config::ENV_SANDBOX,
  api_key: ENV["KIRIMINAJA_API_KEY"],
)

set :port, 3000
set :bind, "0.0.0.0"

before { content_type :json }

# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

get "/" do
  JSON.generate({
    routes: {
      "/provinces"                 => "GET  - List all provinces",
      "/cities/:provinsi_id"       => "GET  - Cities in a province",
      "/districts/:kabupaten_id"   => "GET  - Districts in a city",
      "/sub-districts/:kecamatan_id" => "GET  - Sub-districts in a district",
      "/districts-by-name/:search" => "GET  - Search districts by name",
      "/couriers"                  => "GET  - List available couriers",
      "/couriers/group"            => "GET  - Courier groups",
      "/couriers/:code"            => "GET  - Courier detail",
      "/pickup/schedules"          => "GET  - Pickup schedules",
      "/tracking/:order_id"        => "GET  - Track express order",
      "/instant/tracking/:order_id" => "GET  - Track instant order",
    },
  })
end

# -- Address ---------------------------------------------------------------

get "/provinces" do
  JSON.generate(CLIENT.address.provinces)
end

get "/cities/:provinsi_id" do
  JSON.generate(CLIENT.address.cities(params[:provinsi_id].to_i))
end

get "/districts/:kabupaten_id" do
  JSON.generate(CLIENT.address.districts(params[:kabupaten_id].to_i))
end

get "/sub-districts/:kecamatan_id" do
  JSON.generate(CLIENT.address.sub_districts(params[:kecamatan_id].to_i))
end

get "/districts-by-name/:search" do
  JSON.generate(CLIENT.address.districts_by_name(params[:search]))
end

# -- Courier ---------------------------------------------------------------

get "/couriers" do
  JSON.generate(CLIENT.courier.list)
end

get "/couriers/group" do
  JSON.generate(CLIENT.courier.group)
end

get "/couriers/:code" do
  JSON.generate(CLIENT.courier.detail(params[:code]))
end

# -- Pickup ----------------------------------------------------------------

get "/pickup/schedules" do
  JSON.generate(CLIENT.pickup.schedules)
end

# -- Order — Express -------------------------------------------------------

get "/tracking/:order_id" do
  JSON.generate(CLIENT.order.express.track(params[:order_id]))
end

# -- Order — Instant -------------------------------------------------------

get "/instant/tracking/:order_id" do
  JSON.generate(CLIENT.order.instant.track(params[:order_id]))
end
