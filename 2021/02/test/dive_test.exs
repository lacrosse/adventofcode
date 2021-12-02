defmodule DiveTest do
  use ExUnit.Case, async: true
  doctest Dive

  test "solves" do
    assert Dive.solve() == {1_670_340, 1_954_293_920}
  end
end
