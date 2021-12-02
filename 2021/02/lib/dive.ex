defmodule Dive do
  def solve do
    "input.txt"
    |> File.read!()
    |> solve_input()
  end

  @doc """
    iex> input = \"\"\"
    ...> forward 5
    ...> down 5
    ...> forward 8
    ...> up 3
    ...> down 8
    ...> forward 2
    ...> \"\"\"
    iex> Dive.solve_input(input)
    {150, 900}
  """
  def solve_input(input) do
    {position, depth, aim} =
      input
      |> String.split(~r/\n/, trim: true)
      |> Enum.map(fn line ->
        [op, str] = line |> String.split(" ")
        {op, str |> String.to_integer()}
      end)
      |> Enum.reduce({0, 0, 0}, fn
        {"forward", x}, {position, depth, aim} ->
          {position + x, depth + aim * x, aim}

        {"down", x}, {position, depth, aim} ->
          {position, depth, aim + x}

        {"up", x}, {position, depth, aim} ->
          {position, depth, aim - x}
      end)

    {position * aim, position * depth}
  end
end
