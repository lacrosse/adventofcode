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

  def evolve(%__MODULE__{} = state, 0), do: state

  def evolve(%__MODULE__{} = state, generations) do
    evolved_state =
      state
      |> evolve_pottery()
      |> observe(generations)

    prevent_generational_drift(state, evolved_state, generations)
  end

  defp prevent_generational_drift(%__MODULE__{} = state_1, %__MODULE__{} = state_2, generations) do
    case generational_drift(state_1, state_2) do
      {true, generational_drift} ->
        %__MODULE__{state_1 | offset: state_1.offset + generational_drift * generations}

      false ->
        evolve(state_2, generations - 1)
    end
  end

  defp generational_drift(%__MODULE__{} = state_1, %__MODULE__{} = state_2) do
    if state_1.pottery == state_2.pottery do
      {true, state_2.offset - state_1.offset}
    else
      false
    end
  end

  def sum_of_pots(%__MODULE__{pottery: pottery, offset: offset}) do
    pottery
    |> Enum.with_index(offset)
    |> Enum.filter(fn {v, _} -> v == true end)
    |> Enum.reduce(0, fn {_, i}, acc -> acc + i end)
  end

  defp evolve_pottery(%__MODULE__{} = state) do
    pottery_with_wasteland = state.pottery ++ for(_ <- 1..4, do: :wasteland)

    {_, reversed_pottery, offset_adjustment} =
      Enum.reduce(pottery_with_wasteland, {:wasteland, [], -2}, &evolve_pot(&1, &2, state.notes))

    pottery =
      reversed_pottery
      |> trim_leading()
      |> Enum.reverse()

    %__MODULE__{state | pottery: pottery, offset: state.offset + offset_adjustment}
  end

  defp evolve_pot(pot, {current_last_four, pottery, current_offset}, notes) do
    {current_window, new_last_four} = shift_window(pot, current_last_four)

    {new_history, new_offset} =
      case Map.fetch!(notes, current_window) do
        false ->
          case pottery do
            [] -> {pottery, current_offset + 1}
            _ -> {[false | pottery], current_offset}
          end

        true ->
          {[true | pottery], current_offset}
      end

    {new_last_four, new_history, new_offset}
  end

  defp trim_leading(pottery) do
    {_, new_reversed_pottery} = Enum.split_while(pottery, &(!&1))
    new_reversed_pottery
  end

  defp to_bool(@plant), do: true
  defp to_bool(@no_plant), do: false

  defp to_plant(true), do: @plant
  defp to_plant(false), do: @no_plant

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

    mainland_notes = Map.merge(empty_notes, notes)

    singles = for one <- plantiness, do: {[one], 4}
    doubles = for {single, _} <- singles, one <- plantiness, do: {[one | single], 3}
    triples = for {double, _} <- doubles, one <- plantiness, do: {[one | double], 2}
    quadruples = for {triple, _} <- triples, one <- plantiness, do: {[one | triple], 1}
    incompletes = singles ++ doubles ++ triples ++ quadruples

    borderland_window_lacks =
      Enum.map(incompletes, fn {inc, lack} -> {{:wasteland, inc}, lack} end) ++
        Enum.map(incompletes, fn {inc, lack} -> {{inc, :wasteland}, lack} end)

    borderland_notes =
      for {window, lack} <- borderland_window_lacks, into: %{} do
        original_window = materialize_wasteland(window, lack)

        {window, Map.fetch!(mainland_notes, original_window)}
      end

    Map.merge(mainland_notes, borderland_notes)
  end

  defp observe(%__MODULE__{pottery: pottery, offset: offset} = state, gens) do
    if System.get_env("DEBUG") do
      IO.puts("#{gens} left: #{offset} |#{pottery |> Enum.map(&to_plant/1) |> Enum.join()}")
    end

    state
  end

  defp materialize_wasteland({inc, :wasteland}, lack), do: inc ++ for(_ <- 1..lack, do: false)
  defp materialize_wasteland({:wasteland, inc}, lack), do: for(_ <- 1..lack, do: false) ++ inc

  defp shift_window(:wasteland, [_, two, three, four] = current) do
    {{current, :wasteland}, {[two, three, four], :wasteland}}
  end

  defp shift_window(:wasteland, {[_, two, three], :wasteland} = current) do
    {current, {[two, three], :wasteland}}
  end

  defp shift_window(:wasteland, {[_, two], :wasteland} = current) do
    {current, {[two], :wasteland}}
  end

  defp shift_window(:wasteland, {[_], :wasteland} = current) do
    {current, :wasteland}
  end

  defp shift_window(pot, :wasteland) do
    s = {:wasteland, [pot]}
    {s, s}
  end

  defp shift_window(pot, {:wasteland, [one]}) do
    s = {:wasteland, [one, pot]}
    {s, s}
  end

  defp shift_window(pot, {:wasteland, [one, two]}) do
    s = {:wasteland, [one, two, pot]}
    {s, s}
  end

  defp shift_window(pot, {:wasteland, [one, two, three]}) do
    s = [one, two, three, pot]
    {{:wasteland, s}, s}
  end

  defp shift_window(val, [one, two, three, four]) do
    s = [two, three, four, val]
    {[one | s], s}
  end
end
