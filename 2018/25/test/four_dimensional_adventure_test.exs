defmodule FourDimensionalAdventureTest do
  use ExUnit.Case
  doctest FourDimensionalAdventure

  test "solves" do
    assert FourDimensionalAdventure.solve() == 367
  end
end
