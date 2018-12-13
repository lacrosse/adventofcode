defmodule ChronalCharge.Grid do
  def init(serial_number) do
    for x <- 1..300,
        y <- 1..300,
        do: {{x, y}, cell_power({x, y}, serial_number)},
        into: %{}
  end

  def solve(grid) do
    {coords, _} =
      for x_range <- Enum.chunk_every(1..300, 3, 1),
          y_range <- Enum.chunk_every(1..300, 3, 1) do
        [x | _] = x_range
        [y | _] = y_range

        power = Enum.sum(for(x <- x_range, y <- y_range, do: Map.get(grid, {x, y})))

        {{x, y}, power}
      end
      |> Enum.max_by(&elem(&1, 1))

    coords
  end

  defp cell_power({x, y}, serial_number) do
    rack_id = x + 10
    rem(div((rack_id * y + serial_number) * rack_id, 100), 10) - 5
  end
end
