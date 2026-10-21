# frozen_string_literal: true

module KiriminAja
  module Services
    class CreditService
      def initialize(http)
        @http = http
      end

      def balance
        @http.get_json("/api/mitra/v6.2/credit/balance")
      end

      # Extract the numeric balance from all response envelope variants seen
      # by the API. `balance` remains raw for backward compatibility.
      def amount
        response = balance
        unless response.is_a?(Hash)
          raise "Credit balance is missing from the API response"
        end
        if response["status"] == false
          raise(response["text"] || response["message"] || "Failed to fetch credit balance")
        end

        %w[results result data payload].each do |key|
          value = response[key]
          next unless value.is_a?(Hash)

          amount = numeric(value["balance"])
          return amount unless amount.nil?
        end
        amount = numeric(response["balance"])
        return amount unless amount.nil?

        raise "Credit balance is missing from the API response"
      end

      private

      def numeric(value)
        return value if value.is_a?(Numeric)
        if value.is_a?(String) && value.strip.match?(/\A[+-]?(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?\z/)
          return value.strip.to_i if value.strip.match?(/\A[+-]?\d+\z/)

          return value.to_f
        end

        nil
      end
    end
  end
end
