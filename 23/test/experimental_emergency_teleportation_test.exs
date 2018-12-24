defmodule ExperimentalEmergencyTeleportationTest do
  use ExUnit.Case
  doctest ExperimentalEmergencyTeleportation

  test "solves" do
    assert ExperimentalEmergencyTeleportation.solve() == {383, 100_474_026}
  end
end
