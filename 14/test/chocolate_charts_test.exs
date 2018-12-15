defmodule ChocolateChartsTest do
  use ExUnit.Case

  @tag timeout: 180_000
  test "solves" do
    assert ChocolateCharts.solve() == {"8176111038", 20_225_578}
  end
end
