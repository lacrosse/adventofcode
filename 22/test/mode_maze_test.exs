defmodule ModeMazeTest do
  use ExUnit.Case
  doctest ModeMaze

  test "solves" do
    assert ModeMaze.solve() == {7901, 1087}
  end
end
