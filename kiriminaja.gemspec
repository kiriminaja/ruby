# frozen_string_literal: true

require_relative "lib/kiriminaja"

Gem::Specification.new do |spec|
  spec.name          = "kiriminaja"
  spec.version       = KiriminAja::VERSION
  spec.authors       = ["KiriminAja Team"]
  spec.email         = ["tech@kiriminaja.com"]

  spec.summary       = "Official Ruby SDK for the KiriminAja logistics API"
  spec.description   = "Ruby SDK for the KiriminAja logistics API. Supports address lookup, coverage area pricing, order management (express & instant), courier services, pickup scheduling, and payments."
  spec.homepage      = "https://developer.kiriminaja.com"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"]    = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/kiriminaja/ruby"

  spec.files = Dir["lib/**/*.rb"] + ["README.md", "LICENSE", "CODE_OF_CONDUCT.md"]
  spec.require_paths = ["lib"]

  # Zero runtime dependencies — uses only net/http and json from stdlib
end
