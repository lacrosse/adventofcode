defmodule SubterraneanSustainability.State do
  @plant "#"
  @no_plant "."

  defstruct pottery: "", offset: 0, notes: []

  def init(deep_state, notes_from_the_underground) do
    [pottery_string] = Regex.run(~r/\Ainitial state: (.+)\z/, deep_state, capture: :all_but_first)

    pottery =
      pottery_string
      |> String.codepoints()
      |> Enum.map(&to_bool/1)

    notes =
      notes_from_the_underground
      |> Enum.map(fn note_ftu ->
        [from, to] = Regex.run(~r/\A(.{5}) => (.)\z/, note_ftu, capture: :all_but_first)
        {from |> String.codepoints() |> Enum.map(&to_bool/1), to_bool(to)}
      end)
      |> Enum.into(%{})
      |> complete_notes()

    %__MODULE__{pottery: pottery, offset: 0, notes: notes}
  end

  def evolute(%__MODULE__{} = state, 0), do: state

  def evolute(%__MODULE__{} = state, generations) do
    evolved_state =
      state
      |> extend()
      |> evolve_once()
      |> minimize()

    evolute(evolved_state, generations - 1)
  end

  def sum_of_pots(%__MODULE__{pottery: pottery, offset: offset}) do
    pottery
    |> Enum.zip(Stream.iterate(offset, &(&1 + 1)))
    |> Enum.filter(fn {v, _} -> v == true end)
    |> Enum.reduce(0, fn {_, i}, acc -> acc + i end)
  end

  defp extend(%__MODULE__{} = state) do
    sideline = [false, false, false, false]
    new_pottery = sideline ++ state.pottery ++ sideline
    %__MODULE__{state | pottery: new_pottery, offset: state.offset - 4}
  end

  defp evolve_once(%__MODULE__{} = state) do
    pottery =
      state.pottery
      |> Enum.chunk_every(5, 1, :discard)
      |> Enum.map(fn chunk -> Map.fetch!(state.notes, chunk) end)

    %__MODULE__{state | pottery: pottery, offset: state.offset + 2}
  end

  defp minimize(%__MODULE__{} = state) do
    {leading, new_pottery} =
      state.pottery
      |> Enum.split_while(&(!&1))

    {_, new_reversed_pottery} =
      new_pottery
      |> Enum.reverse()
      |> Enum.split_while(&(!&1))

    new_pottery =
      new_reversed_pottery
      |> Enum.reverse()

    %__MODULE__{
      state
      | pottery: new_pottery,
        offset: state.offset + Enum.count(leading)
    }
  end

  defp to_bool(@plant), do: true
  defp to_bool(@no_plant), do: false

  defp complete_notes(notes) do
    plantiness = [true, false]

    empty_notes =
      for a <- plantiness,
          b <- plantiness,
          c <- plantiness,
          d <- plantiness,
          e <- plantiness,
          do: {[a, b, c, d, e], false},
          into: %{}

    Map.merge(empty_notes, notes)
  end
end
