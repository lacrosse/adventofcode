defmodule ChocolateCharts.Chart do
  defstruct list: %{0 => 3, 1 => 7}, elf_one: 0, elf_two: 1

  @doc """
    iex> %ChocolateCharts.Chart{} |> ChocolateCharts.Chart.score_after(5)
    "0124515891"

    iex> %ChocolateCharts.Chart{} |> ChocolateCharts.Chart.score_after(18)
    "9251071085"

    iex> %ChocolateCharts.Chart{} |> ChocolateCharts.Chart.score_after(2018)
    "5941429882"

    iex> %ChocolateCharts.Chart{} |> ChocolateCharts.Chart.score_after(9)
    "5158916779"
  """
  def score_after(%__MODULE__{list: list}, offset) when map_size(list) >= offset + 10 do
    Enum.join(for n <- offset..(offset + 9), do: Map.get(list, n))
  end

  def score_after(%__MODULE__{} = chart, offset) do
    {_, new_chart} = chart |> make_more_recipes()

    new_chart |> score_after(offset)
  end

  @doc """
    iex> %ChocolateCharts.Chart{} |> ChocolateCharts.Chart.detect("51589")
    9

    iex> %ChocolateCharts.Chart{} |> ChocolateCharts.Chart.detect("01245")
    5

    iex> %ChocolateCharts.Chart{} |> ChocolateCharts.Chart.detect("92510")
    18

    iex> %ChocolateCharts.Chart{} |> ChocolateCharts.Chart.detect("59414")
    2018
  """
  def detect(chart, number_string) do
    number_list =
      number_string
      |> String.codepoints()
      |> Enum.map(&String.to_integer/1)

    tail =
      chart
      |> Stream.unfold(&make_more_recipes/1)
      |> Stream.flat_map(& &1)

    chart_stream =
      chart
      |> static_list()
      |> Stream.concat(tail)

    {_, index} =
      chart_stream
      |> Stream.chunk_every(Enum.count(number_list), 1)
      |> Stream.with_index()
      |> Enum.find(fn
        {^number_list, _} -> true
        _ -> false
      end)

    index
  end

  defp make_more_recipes(%__MODULE__{} = chart) do
    elf_one_score = Map.get(chart.list, chart.elf_one)
    elf_two_score = Map.get(chart.list, chart.elf_two)
    full_score = elf_one_score + elf_two_score
    ones = rem(full_score, 10)
    new_scores = if full_score > 9, do: [div(full_score, 10), ones], else: [ones]

    new_list = Enum.reduce(new_scores, chart.list, &Map.put(&2, map_size(&2), &1))
    new_list_size = map_size(new_list)
    new_elf_one = rem(chart.elf_one + elf_one_score + 1, new_list_size)
    new_elf_two = rem(chart.elf_two + elf_two_score + 1, new_list_size)

    {new_scores, %__MODULE__{chart | list: new_list, elf_one: new_elf_one, elf_two: new_elf_two}}
  end

  defp static_list(%__MODULE__{list: list}) do
    for i <- 0..(map_size(list) - 1), do: Map.get(list, i)
  end
end
