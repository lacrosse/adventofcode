defmodule LanternfishTest do
  use ExUnit.Case
  doctest Lanternfish

  test "solves" do
    assert Lanternfish.solve() == {388_419, 1_740_449_478_328}
  end
end
