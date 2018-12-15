defmodule ChocolateCharts.Chart do
  defstruct list: %{0 => 3, 1 => 7}, elf_one: 0, elf_two: 1

  def score_after(%__MODULE__{list: list}, offset) when map_size(list) >= offset + 10 do
    Enum.join(for n <- offset..(offset + 9), do: Map.get(list, n))
  end

  def score_after(%__MODULE__{} = chart, offset) do
    chart
    |> make_more_recipes()
    |> score_after(offset)
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

    %__MODULE__{chart | list: new_list, elf_one: new_elf_one, elf_two: new_elf_two}
  end
end
