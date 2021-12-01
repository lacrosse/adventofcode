defmodule Day06Test do
  use ExUnit.Case
  doctest Day06

  test 'solve' do
    assert Day06.solve() == {3223, 40495}
  end
end
