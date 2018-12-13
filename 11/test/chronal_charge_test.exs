defmodule ChronalChargeTest do
  use ExUnit.Case
  doctest ChronalCharge

  test "solve" do
    assert ChronalCharge.solve() == {{{235, 20}, 3, 31}, {{237, 223}, 14, 83}}
  end
end
