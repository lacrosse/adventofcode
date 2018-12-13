defmodule ChronalCharge.Grid do
  def init(serial_number) do
    for x <- 1..300 do
      for y <- 1..300 do
        {{x, y}, cell_power({x, y}, serial_number)}
      end
    end
  end

  def solve(grid) do
    {coords, _} =
      for rack_pack <- Enum.chunk_every(grid, 3, 1),
          offset <- 0..297 do
        rack_pack
        |> Enum.flat_map(&(&1 |> Enum.drop(offset) |> Enum.take(3)))
      end
      |> Enum.map(fn [{coords, _} | _] = cells ->
        power = Enum.reduce(cells, 0, fn {_, power}, acc -> acc + power end)

        {coords, power}
      end)
      |> Enum.max_by(&elem(&1, 1))

    coords
  end

  defp cell_power({x, y}, serial_number) do
    rack_id = x + 10
    rem(div((rack_id * y + serial_number) * rack_id, 100), 10) - 5
  end
end
