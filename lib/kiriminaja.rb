# frozen_string_literal: true

require_relative "kiriminaja/client"

module KiriminAja
  VERSION = begin
    v = ENV.fetch("GEM_VERSION") {
      `git describe --tags --abbrev=0 2>/dev/null`.strip
    }
    v = v.sub(/\Av/, "")
    v.empty? ? "0.0.0" : v
  end
end
