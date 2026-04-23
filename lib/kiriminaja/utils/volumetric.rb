# frozen_string_literal: true

module KiriminAja
  module Utils
    module Volumetric
      module_function

      # Returns { length:, width:, height: } as the smallest bounding box
      # across vertical / horizontal / side-by-side stacking strategies.
      #
      # Each item is a Hash with keys: :qty, :length, :width, :height
      # (string keys are also accepted). Missing values default to 0; qty < 1
      # is treated as 1.
      def calculate(items)
        return { length: 0, width: 0, height: 0 } if items.nil? || items.empty?

        l_vert = w_vert = h_vert = 0
        l_hor  = w_hor  = h_hor  = 0
        l_side = w_side = h_side = 0

        items.each do |it|
          qty = (fetch(it, :qty) || 1).to_i
          qty = 1 if qty < 1
          l = fetch(it, :length) || 0
          w = fetch(it, :width)  || 0
          h = fetch(it, :height) || 0

          h_vert += h * qty
          l_vert = l if l > l_vert
          w_vert = w if w > w_vert

          l_hor += l * qty
          h_hor = h if h > h_hor
          w_hor = w if w > w_hor

          w_side += w * qty
          h_side = h if h > h_side
          l_side = l if l > l_side
        end

        vol_vert = l_vert * w_vert * h_vert
        vol_hor  = l_hor  * w_hor  * h_hor
        vol_side = l_side * w_side * h_side

        if vol_vert <= vol_hor && vol_vert <= vol_side
          { length: l_vert, width: w_vert, height: h_vert }
        elsif vol_hor <= vol_side
          { length: l_hor, width: w_hor, height: h_hor }
        else
          { length: l_side, width: w_side, height: h_side }
        end
      end

      def fetch(item, key)
        item[key] || item[key.to_s]
      end
      private_class_method :fetch
    end
  end
end
