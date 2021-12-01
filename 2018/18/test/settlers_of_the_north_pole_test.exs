defmodule SettlersOfTheNorthPoleTest do
  use ExUnit.Case
  doctest SettlersOfTheNorthPole

  @tag timeout: 5000
  test "solves" do
    assert SettlersOfTheNorthPole.solve() == {549_936, 206_304}
  end
end
