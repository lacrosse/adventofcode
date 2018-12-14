defmodule MineCartMadness.Cart do
  defstruct dxn: nil, next_intxn: :left

  def orient(%__MODULE__{dxn: dxn, next_intxn: next_intxn} = cart, :cross) do
    %__MODULE__{dxn: turn(next_intxn, dxn), next_intxn: switch_intxn(next_intxn)}
  end

  def orient(%__MODULE__{dxn: dxn} = cart, rail) do
    %__MODULE__{cart | dxn: rail |> turn_from_dxn_over_rail(dxn)}
  end

  defp turn(:left, :north), do: :west
  defp turn(:left, :west), do: :south
  defp turn(:left, :south), do: :east
  defp turn(:left, :east), do: :north
  defp turn(:right, :north), do: :east
  defp turn(:right, :east), do: :south
  defp turn(:right, :south), do: :west
  defp turn(:right, :west), do: :north
  defp turn(:straight, dir), do: dir

  defp turn(a, b) do
    raise "cha #{a} #{b}"
  end

  defp switch_intxn(:left), do: :straight
  defp switch_intxn(:straight), do: :right
  defp switch_intxn(:right), do: :left

  defp dxn_over_rail(:deuce, :north), do: :left
  defp dxn_over_rail(:deuce, :east), do: :right
  defp dxn_over_rail(:deuce, :south), do: :left
  defp dxn_over_rail(:deuce, :west), do: :right
  defp dxn_over_rail(:ad, :north), do: :right
  defp dxn_over_rail(:ad, :east), do: :left
  defp dxn_over_rail(:ad, :south), do: :right
  defp dxn_over_rail(:ad, :west), do: :left
  defp dxn_over_rail(:straight, _), do: :straight

  defp turn_from_dxn_over_rail(rail, dxn) do
    rail |> dxn_over_rail(dxn) |> turn(dxn)
  end
end
