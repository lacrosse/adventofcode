defmodule ChocolateCharts do
  alias ChocolateCharts.Chart

  def solve do
    'input.txt'
    |> File.read!()
    |> String.trim_trailing()
    |> solve_input()
  end

  def solve_input(input) do
    first = %Chart{} |> Chart.score_after(String.to_integer(input))

    second = %Chart{} |> Chart.detect(input)

    {first, second}
  end
end
