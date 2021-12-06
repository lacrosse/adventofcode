defmodule HydrothermalVenture do
  def solve do
    "input.txt"
    |> File.read!()
    |> solve_input()
  end

  @doc """
  ## Examples
    iex> input = \"\"\"
    ...> 0,9 -> 5,9
    ...> 8,0 -> 0,8
    ...> 9,4 -> 3,4
    ...> 2,2 -> 2,1
    ...> 7,0 -> 7,4
    ...> 6,4 -> 2,0
    ...> 0,9 -> 2,9
    ...> 3,4 -> 1,4
    ...> 0,0 -> 8,8
    ...> 5,5 -> 8,2
    ...> \"\"\"
    iex> HydrothermalVenture.solve_input(input)
    {5, 12}
  """
  def solve_input(input) do
    segments =
      input
      |> String.split(~r/\n/, trim: true)
      |> Enum.map(fn line ->
        [from, to] =
          line
          |> String.split(" -> ")
          |> Enum.map(fn sp ->
            [x, y] = sp |> String.split(",") |> Enum.map(&String.to_integer/1)
            {x, y}
          end)
          |> Enum.sort()

        {from, to}
      end)

    first =
      segments
      |> Enum.filter(fn {{f_x, f_y}, {t_x, t_y}} -> f_x == t_x || f_y == t_y end)
      |> count_intersections()

    second =
      segments
      |> count_intersections()

    {first, second}
  end

  defp count_intersections(segments) do
    segments
    |> Stream.flat_map(fn {{f_x, f_y}, {t_x, t_y}} ->
      if f_x == t_x || f_y == t_y,
        do: for(x <- f_x..t_x, y <- f_y..t_y, do: {x, y}),
        else: Enum.zip(f_x..t_x, f_y..t_y)
    end)
    |> Enum.group_by(& &1)
    |> Enum.count(fn {_, g} -> Enum.count(g) > 1 end)
  end
end
