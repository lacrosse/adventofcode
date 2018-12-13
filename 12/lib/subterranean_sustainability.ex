defmodule SubterraneanSustainability do
  alias SubterraneanSustainability.State

  def solve do
    'input.txt'
    |> File.read!()
    |> solve_input()
  end

  @doc """
    iex> input = \"\"\"
    ...> initial state: #..#.#..##......###...###
    ...>
    ...> ...## => #
    ...> ..#.. => #
    ...> .#... => #
    ...> .#.#. => #
    ...> .#.## => #
    ...> .##.. => #
    ...> .#### => #
    ...> #.#.# => #
    ...> #.### => #
    ...> ##.#. => #
    ...> ##.## => #
    ...> ###.. => #
    ...> ###.# => #
    ...> ####. => #
    ...> \"\"\"
    iex> SubterraneanSustainability.solve_input(input)
    325
  """
  def solve_input(input) do
    [deep_state | notes_from_the_underground] =
      input
      |> String.split(~r/\n/, trim: true)

    State.init(deep_state, notes_from_the_underground)
    |> State.evolute(20)
    |> State.sum_of_pots()
  end
end
