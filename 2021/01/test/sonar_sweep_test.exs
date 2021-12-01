defmodule SonarSweepTest do
  use ExUnit.Case, async: true
  doctest SonarSweep

  test "solves" do
    assert SonarSweep.solve() == {1448, 1471}
  end
end
