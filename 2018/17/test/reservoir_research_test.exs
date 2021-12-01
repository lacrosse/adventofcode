defmodule ReservoirResearchTest do
  use ExUnit.Case
  # doctest ReservoirResearch

  @tag timeout: 5000
  test "solves" do
    assert ReservoirResearch.solve() == {34775, 27086}
  end
end
