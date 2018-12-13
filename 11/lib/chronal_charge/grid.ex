defmodule ChronalCharge.Grid do
  @width 300

  def init(serial_number) do
    for x <- 1..@width,
        y <- 1..@width,
        do: {{x, y}, cell_power({x, y}, serial_number)},
        into: %{}
  end

  @doc """
    iex> 18 |> ChronalCharge.Grid.init() |> ChronalCharge.Grid.solve_for_3() |> elem(0)
    {{33, 45}, 3, 29}

    iex> 42 |> ChronalCharge.Grid.init() |> ChronalCharge.Grid.solve_for_3() |> elem(0)
    {{21, 61}, 3, 30}
  """
  def solve_for_3(grid, cache \\ %{}) do
    {[best_square | _], new_cache} = find_best_squares(grid, 3, cache)
    {best_square, new_cache}
  end

  def solve_for_all(grid, cache \\ %{}) do
    {best_squares, new_cache} = find_best_squares(grid, @width, cache)
    {Enum.max_by(best_squares, fn {_, _, power} -> power end), new_cache}
  end

  defp find_best_squares(grid, top_size, cache) do
    1..top_size
    |> Enum.reduce({[], cache}, fn square_size, {best_squares, current_cache} ->
      {{coords, power}, new_cache} = find_best_square(grid, square_size, current_cache)
      {[{coords, square_size, power} | best_squares], new_cache}
    end)
  end

  defp find_best_square(grid, square_size, cache) do
    range = 1..(@width - square_size + 1)

    squares =
      for x <- range,
          y <- range,
          coords = {x, y},
          do: {coords, square_power(grid, coords, square_size, cache)},
          into: %{}

    new_cache = Map.put(cache, square_size, squares)

    {Enum.max_by(squares, &elem(&1, 1)), new_cache}
  end

  defp square_power(grid, {x, y}, size, cache) do
    half = div(size + 1, 2)
    m_half = size - half

    Enum.sum([
      cached_square_power(grid, {x, y}, half, cache),
      cached_square_power(grid, {x + half, y}, m_half, cache),
      cached_square_power(grid, {x, y + half}, m_half, cache),
      cached_square_power(grid, {x + m_half, y + m_half}, half, cache),
      -cached_square_power(grid, {x + m_half, y + m_half}, half - m_half, cache)
    ])
  end

  defp cached_square_power(_, _, 0, _), do: 0
  defp cached_square_power(grid, coords, 1, _), do: grid |> Map.get(coords)
  defp cached_square_power(_, coords, size, cache), do: cache |> Map.get(size) |> Map.get(coords)

  defp cell_power({x, y}, serial_number) do
    rack_id = x + 10
    rem(div((rack_id * y + serial_number) * rack_id, 100), 10) - 5
  end
end
