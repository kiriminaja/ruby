# frozen_string_literal: true

module KiriminAja
  module Config
    ENV_SANDBOX    = "sandbox"
    ENV_PRODUCTION = "production"

    KA_ENV_URL = {
      ENV_SANDBOX    => "https://tdev.kiriminaja.com",
      ENV_PRODUCTION => "https://client.kiriminaja.com",
    }.freeze
  end
end
