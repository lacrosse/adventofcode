defmodule Day06 do
  alias Day06.{SingleEscape, MultipleEscape}

  @doc """
  Solve day 6.
  """
  def solve do
    regex = ~r/\A(\d+), (\d+)\z/

    sinks =
      'input.txt'
      |> File.read!()
      |> String.split(~r/\n/, trim: true)
      |> Enum.map(fn str ->
        regex
        |> Regex.run(str, capture: :all_but_first)
        |> Enum.map(&String.to_integer/1)
        |> Enum.reduce({}, &Tuple.append(&2, &1))
      end)
      |> MapSet.new()

    {SingleEscape.find_max_finite_area(sinks), MultipleEscape.find_closest_area(sinks, 10000)}
  end
end
