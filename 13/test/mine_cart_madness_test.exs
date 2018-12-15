defmodule MineCartMadnessTest do
  use ExUnit.Case
  doctest MineCartMadness

  @tag timeout: 1000
  test "solves" do
    assert MineCartMadness.solve() == {{43, 111}, {44, 56}}
  end
end
