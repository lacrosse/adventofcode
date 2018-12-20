defmodule RegularMapTest do
  use ExUnit.Case
  doctest RegularMap

  test "solves" do
    assert RegularMap.solve() == {3983, 8486}
  end
end
