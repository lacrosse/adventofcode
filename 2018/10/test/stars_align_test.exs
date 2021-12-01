defmodule StarsAlignTest do
  use ExUnit.Case
  doctest StarsAlign

  test "solve" do
    assert StarsAlign.solve() == {10009, 9}
  end
end
