defmodule ChocolateChartsTest do
  use ExUnit.Case

  @tag timeout: 10000
  test "solves" do
    assert ChocolateCharts.solve() == {"8176111038", nil}
  end
end
