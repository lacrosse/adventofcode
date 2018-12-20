defmodule GoWithTheFlowTest do
  use ExUnit.Case
  doctest GoWithTheFlow

  @tag timeout: 80_000
  test "solves" do
    assert GoWithTheFlow.solve() == {2352, 24_619_952}
  end
end
