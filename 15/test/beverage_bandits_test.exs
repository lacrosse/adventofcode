defmodule BeverageBanditsTest do
  use ExUnit.Case
  doctest BeverageBandits

  @tag timeout: 3000
  test "solves" do
    assert BeverageBandits.solve() == 217_890
  end
end
