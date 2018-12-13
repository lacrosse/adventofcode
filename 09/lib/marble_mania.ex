defmodule MarbleMania do
  alias MarbleMania.Game

  def solve() do
    'input.txt'
    |> File.read!()
    |> String.trim_trailing()
    |> solve_input()
  end

  def solve_input(input) do
    [players, rounds] =
      ~r/\A(\d+) players; last marble is worth (\d+) points\z/
      |> Regex.run(input, capture: :all_but_first)
      |> Enum.map(&String.to_integer/1)

    {solve_game(players, rounds), solve_game(players, rounds * 100)}
  end

  @doc """
    iex> MarbleMania.solve_game(9, 25)
    32

    iex> MarbleMania.solve_game(10, 1618)
    8317

    iex> MarbleMania.solve_game(13, 7999)
    146373

    iex> MarbleMania.solve_game(17, 1104)
    2764

    iex> MarbleMania.solve_game(21, 6111)
    54718

    iex> MarbleMania.solve_game(30, 5807)
    37305
  """
  def solve_game(players, rounds) do
    Game.init(players, rounds)
    |> Game.solve()
  end
end
