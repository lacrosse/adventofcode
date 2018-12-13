defmodule SubterraneanSustainabilityTest do
  use ExUnit.Case
  doctest SubterraneanSustainability

  test "solve" do
    assert SubterraneanSustainability.solve() == 3241
  end
end
