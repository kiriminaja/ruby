# frozen_string_literal: true

require_relative "kiriminaja/client"

module KiriminAja
  VERSION = ENV.fetch("GEM_VERSION") {
    tag = `git describe --tags --abbrev=0 2>/dev/null`.strip
    tag.start_with?("v") ? tag[1..] : "0.0.0"
  }
end
