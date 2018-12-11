defmodule Day08Test do
  use ExUnit.Case
  doctest Day08

  test "solve" do
    assert Day08.solve() == {41028, 20849}
  end
end
