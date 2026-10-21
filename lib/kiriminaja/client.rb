# frozen_string_literal: true

require_relative "config/api"
require_relative "config/client"
require_relative "http/request"
require_relative "types/enums"
require_relative "types/address"
require_relative "types/order"
require_relative "services/address/address"
require_relative "services/awb/awb"
require_relative "services/calculations/calculations"
require_relative "services/coverage_area/coverage_area"
require_relative "services/courier/courier"
require_relative "services/credit/credit"
require_relative "services/order/order"
require_relative "services/payment/payment"
require_relative "services/pickup/pickup"
require_relative "services/profile/profile"
require_relative "services/preference/preference"

module KiriminAja
  class Client
    attr_reader :address, :awb, :calculations, :coverage_area, :courier, :credit, :order, :payment, :pickup, :profile, :preference

    def initialize(env: Config::ENV_SANDBOX, api_key: nil, base_url: nil, http_client: nil)
      config = Config::ClientConfig.new(
        env: env,
        api_key: api_key,
        base_url: base_url,
        http_client: http_client,
      )
      http = Http::Request.new(config)

      @address = Services::AddressService.new(http)
      @awb = Services::AWBService.new(http)
      @calculations = Services::CalculationsService.new(http)
      @coverage_area = Services::CoverageAreaService.new(http)
      @courier = Services::CourierService.new(http)
      @credit = Services::CreditService.new(http)
      @order = Services::OrderService.new(http)
      @payment = Services::PaymentService.new(http)
      @pickup = Services::PickupService.new(http)
      @profile = Services::ProfileService.new(http)
      @preference = Services::PreferenceService.new(http)
    end
  end
end
