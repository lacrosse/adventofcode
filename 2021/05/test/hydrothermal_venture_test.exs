defmodule HydrothermalVentureTest do
  use ExUnit.Case
  doctest HydrothermalVenture

  test "solves" do
    assert HydrothermalVenture.solve() == {5698, 15463}
  end
end
