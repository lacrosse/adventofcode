defmodule Day07Test do
  use ExUnit.Case
  doctest Day07

  test "solve" do
    assert Day07.solve() == {"JKNSTHCBGRVDXWAYFOQLMPZIUE", 755}
  end
end
