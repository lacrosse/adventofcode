defmodule ImmuneSystemSimulatorTest do
  use ExUnit.Case
  doctest ImmuneSystemSimulator

  test "solves" do
    assert ImmuneSystemSimulator.solve() == {25088, 2002}
  end
end
