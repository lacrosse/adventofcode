defmodule ChocolateChartsTest do
  use ExUnit.Case
  # doctest ChocolateCharts

  @tag timeout: 2500
  test "solves" do
    assert ChocolateCharts.solve() == "8176111038"
  end
end
