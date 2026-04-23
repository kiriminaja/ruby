# frozen_string_literal: true

require "minitest/autorun"
require "kiriminaja"

class VolumetricTest < Minitest::Test
  V = KiriminAja::Utils::Volumetric

  def test_empty
    assert_equal({ length: 0, width: 0, height: 0 }, V.calculate([]))
  end

  def test_single_item
    assert_equal(
      { length: 10, width: 5, height: 3 },
      V.calculate([{ qty: 1, length: 10, width: 5, height: 3 }])
    )
  end

  def test_vertical_wins
    assert_equal(
      { length: 10, width: 10, height: 4 },
      V.calculate([{ qty: 2, length: 10, width: 10, height: 2 }])
    )
  end

  def test_horizontal_wins
    out = V.calculate([
      { qty: 5, length: 2,  width: 10, height: 10 },
      { qty: 1, length: 10, width: 1,  height: 1 }
    ])
    assert_equal({ length: 20, width: 10, height: 10 }, out)
  end

  def test_side_wins
    out = V.calculate([
      { qty: 5, length: 10, width: 2,  height: 10 },
      { qty: 1, length: 1,  width: 10, height: 1 }
    ])
    assert_equal({ length: 10, width: 20, height: 10 }, out)
  end

  def test_qty_zero_treated_as_one
    assert_equal(
      { length: 10, width: 5, height: 3 },
      V.calculate([{ qty: 0, length: 10, width: 5, height: 3 }])
    )
  end

  def test_string_keys_accepted
    assert_equal(
      { length: 10, width: 5, height: 3 },
      V.calculate([{ "qty" => 1, "length" => 10, "width" => 5, "height" => 3 }])
    )
  end
end
