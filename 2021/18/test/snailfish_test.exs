defmodule SnailfishTest do
  use ExUnit.Case, async: true
  doctest Snailfish

  test "greets the world" do
    assert Snailfish.solve() == {4433, 4559}
  end
end
