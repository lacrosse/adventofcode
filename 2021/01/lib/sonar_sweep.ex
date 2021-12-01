defmodule SonarSweep do
  @spec solve :: {non_neg_integer, non_neg_integer}
  def solve do
    "input.txt"
    |> File.read!()
    |> solve_input()
  end

  @spec solve_input(binary) :: {non_neg_integer, non_neg_integer}
  @doc """
    iex> input = \"\"\"
    ...> 0
    ...> 2
    ...> 1
    ...> 93
    ...> \"\"\"
    iex> SonarSweep.solve_input(input)
    {2, 1}
  """
  def solve_input(input) do
    ints =
      input
      |> String.split(~r/\n/, trim: true)
      |> Stream.map(&String.to_integer/1)

    first =
      ints
      |> count_increases()

    second =
      ints
      |> each_cons(3)
      |> Stream.map(&Enum.sum/1)
      |> count_increases()

    {first, second}
  end

  defp count_increases(stream) do
    stream
    |> each_cons(2)
    |> Stream.filter(fn [a, b] -> a < b end)
    |> Enum.count()
  end

  defp each_cons(stream, n), do: stream |> Stream.chunk_every(n, 1, :discard)
end
