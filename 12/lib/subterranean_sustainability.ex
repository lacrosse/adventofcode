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
    {325, 999999999374}
  """
  def solve_input(input) do
    [deep_state | notes_from_the_underground] =
      input
      |> String.split(~r/\n/, trim: true)

    state = State.init(deep_state, notes_from_the_underground)
    state_20 = State.evolve(state, 20)
    state_50_billion = State.evolve(state_20, 50_000_000_000 - 20)

    {State.sum_of_pots(state_20), State.sum_of_pots(state_50_billion)}
  end
end
