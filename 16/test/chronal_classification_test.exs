defmodule ChronalClassificationTest do
  use ExUnit.Case
  doctest ChronalClassification

  test "solves" do
    assert ChronalClassification.solve() == 651
  end
end
