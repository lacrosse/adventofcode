defmodule MarbleMania.Game do
  alias MarbleMania.Circle

  defstruct players: 1,
            rounds: 1,
            current_marble: 1,
            circle: %Circle{list: %{0 => {0, 0}}, current: 0},
            scores: %{}

  def init(players, rounds) do
    %__MODULE__{players: players, rounds: rounds}
  end

  def solve(%__MODULE__{rounds: 0, scores: scores}) do
    {_, max_score} = Enum.max_by(scores, &elem(&1, 1))
    max_score
  end

  def solve(%__MODULE__{current_marble: current_marble} = game)
      when rem(current_marble, 23) == 0 do
    current_player = rem(current_marble - 1, game.players) + 1
    {snatch, new_circle} = Circle.remove(game.circle, -7)
    winnings = current_marble + snatch
    new_scores = Map.update(game.scores, current_player, winnings, &(&1 + winnings))

    solve(%__MODULE__{
      game
      | rounds: game.rounds - 1,
        current_marble: current_marble + 1,
        circle: new_circle,
        scores: new_scores
    })
  end

  def solve(%__MODULE__{} = game) do
    solve(%__MODULE__{
      game
      | rounds: game.rounds - 1,
        current_marble: game.current_marble + 1,
        circle: Circle.insert(game.circle, game.current_marble)
    })
  end
end
