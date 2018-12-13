defmodule MarbleManiaTest do
  use ExUnit.Case
  doctest MarbleMania

  test "solve" do
    assert MarbleMania.solve() == {416_424, 3_498_287_922}
  end
end
