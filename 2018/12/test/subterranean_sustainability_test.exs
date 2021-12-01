defmodule SubterraneanSustainabilityTest do
  use ExUnit.Case
  doctest SubterraneanSustainability

  test "solve" do
    assert SubterraneanSustainability.solve() == {3241, 2_749_999_999_911}
  end
end
