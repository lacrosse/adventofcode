defmodule BeverageBanditsTest do
  use ExUnit.Case
  doctest BeverageBandits

  @tag timeout: 6000
  test "solves" do
    assert BeverageBandits.solve() == {217_890, 43645}
  end
end
