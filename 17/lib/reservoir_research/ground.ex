defmodule ReservoirResearch.Ground do
  defstruct depth: 0,
            clay: %MapSet{},
            stale: %MapSet{},
            flow: %MapSet{},
            sources: [{500, 0}]

  @type t :: %__MODULE__{}
  @type coords :: {pos_integer(), pos_integer()}

  @vein ~r/\A([xy])=(\d+), ([xy])=(\d+)..(\d+)\z/

  @spec parse(binary()) :: t()
  def parse(input) do
    clay =
      input
      |> String.split(~r/\n/, trim: true)
      |> Enum.flat_map(fn line ->
        [line_axis, line_coord_str, range_axis, range_start_str, range_end_str] =
          Regex.run(@vein, line, capture: :all_but_first)

        [line_coord, range_start, range_end] =
          [line_coord_str, range_start_str, range_end_str]
          |> Enum.map(&String.to_integer/1)

        case {line_axis, range_axis} do
          {"x", "y"} -> for y <- range_start..range_end, do: {line_coord, y}
          {"y", "x"} -> for x <- range_start..range_end, do: {x, line_coord}
        end
      end)
      |> Enum.into(%MapSet{})

    {_, depth} = clay |> Enum.max_by(fn {_, y} -> y end)

    %__MODULE__{clay: clay, depth: depth}
  end

  @spec pour(t(), [coords()]) :: t()
  def pour(%__MODULE__{} = ground, tapped_sources \\ [], rounds \\ 0) do
    case do_pour(ground, tapped_sources) do
      {:done, ground} -> ground
      {:keep, new_ground, new_tapped_sources} -> pour(new_ground, new_tapped_sources, rounds + 1)
    end
  end

  defp do_pour(%__MODULE__{sources: []} = ground, _), do: {:done, ground}

  defp do_pour(
         %__MODULE__{
           sources: [{source_x, source_y} = source | sources_tail],
           depth: depth,
           clay: clay,
           stale: stale,
           flow: flow
         } = ground,
         tapped_sources
       ) do
    if System.get_env("DEBUG"), do: visualize(ground)

    base = MapSet.union(clay, stale)

    reversed_column_of_water =
      (for(y <- source_y..depth, do: {source_x, y}) ++ [:abyss])
      |> Enum.take_while(fn coords -> !MapSet.member?(base, coords) end)
      |> Enum.reverse()

    result =
      reversed_column_of_water
      |> reduce_with_tail_while(
        {flow, stale},
        fn
          {:abyss, column_tail}, {current_flow, current_stale} ->
            new_flow = MapSet.union(current_flow, MapSet.new(column_tail))
            {:halt, {{new_flow, current_stale}, []}}

          {{h_source_x, h_source_y} = h_source, column_tail}, {current_flow, current_stale} ->
            current_base = MapSet.union(clay, current_stale)

            qvb = fn x ->
              Enum.reduce_while(x, [], fn {x, y}, current_fill ->
                cond do
                  MapSet.member?(current_base, {x, y}) ->
                    {:halt, {[], current_fill}}

                  !MapSet.member?(current_base, {x, y + 1}) ->
                    {:halt, {[{x, y}], current_fill}}

                  true ->
                    {:cont, [{x, y} | current_fill]}
                end
              end)
            end

            {left_sources, left_fill} =
              Stream.iterate(h_source_x - 1, &(&1 - 1))
              |> Stream.map(&{&1, h_source_y})
              |> qvb.()

            {right_sources, right_fill} =
              Stream.iterate(h_source_x + 1, &(&1 + 1))
              |> Stream.map(&{&1, h_source_y})
              |> qvb.()

            found_sources = left_sources ++ right_sources

            fill = [h_source] ++ left_fill ++ right_fill
            fill_set = MapSet.new(fill)

            if MapSet.intersection(current_flow, fill_set) == fill_set do
              new_flow_with_column =
                current_flow
                |> MapSet.union(MapSet.new(column_tail))

              if length(found_sources) == 0 do
                new_flow_with_column_without_fill =
                  new_flow_with_column
                  |> MapSet.difference(fill_set)

                new_stale =
                  current_stale
                  |> MapSet.union(fill_set)

                {:halt, {{new_flow_with_column_without_fill, new_stale}, []}}
              else
                {:halt, {{new_flow_with_column, current_stale}, []}}
              end
            else
              case found_sources do
                [] ->
                  new_stale = MapSet.union(current_stale, fill_set)
                  {:cont, {current_flow, new_stale}}

                _ ->
                  new_flow_with_column =
                    MapSet.union(current_flow, MapSet.new(fill ++ column_tail))

                  {:halt, {{new_flow_with_column, current_stale}, found_sources}}
              end
            end
        end
      )

    case result do
      {{new_flow, new_stale}, found_sources} ->
        {:keep,
         %__MODULE__{
           ground
           | flow: new_flow,
             stale: new_stale,
             sources: found_sources ++ sources_tail
         }, [source | tapped_sources]}

      {new_flow, new_stale} ->
        [tapped_source | tapped_tail] = tapped_sources

        {:keep,
         %__MODULE__{
           ground
           | flow: new_flow,
             stale: new_stale,
             sources: [tapped_source | sources_tail]
         }, tapped_tail}
    end
  end

  defp reduce_with_tail_while([], acc, _), do: acc

  defp reduce_with_tail_while([x | tail], acc, reducer) do
    case reducer.({x, tail}, acc) do
      {:halt, new_acc} -> new_acc
      {:cont, new_acc} -> reduce_with_tail_while(tail, new_acc, reducer)
    end
  end

  @spec measure_secondary_water(t()) :: {non_neg_integer(), non_neg_integer()}
  def measure_secondary_water(%__MODULE__{clay: clay, flow: flow, stale: stale}) do
    {{_, min_y}, {_, max_y}} = Enum.min_max_by(clay, &elem(&1, 1))

    total_count =
      MapSet.union(flow, stale)
      |> Enum.reject(fn {_, y} -> y < min_y || y > max_y end)
      |> Enum.count()

    stale_count =
      stale
      |> Enum.reject(fn {_, y} -> y < min_y || y > max_y end)
      |> Enum.count()

    {total_count, stale_count}
  end

  @spec visualize(t) :: t
  def visualize(
        %__MODULE__{
          clay: clay,
          flow: flow,
          stale: stale,
          sources: sources_list,
          depth: depth
        } = ground,
        device \\ :stdio
      ) do
    sources = sources_list |> MapSet.new()

    objects = clay |> MapSet.union(flow) |> MapSet.union(stale) |> MapSet.union(sources)

    {{min_x, _}, {max_x, _}} = Enum.min_max_by(objects, fn {x, _} -> x end)

    for y <- 0..depth do
      string =
        for x <- min_x..max_x do
          cond do
            MapSet.member?(sources, {x, y}) -> "+"
            # MapSet.member?(stale, {x, y}) && MapSet.member?(flow, {x, y}) -> "@"
            MapSet.member?(stale, {x, y}) -> "~"
            MapSet.member?(flow, {x, y}) -> "|"
            MapSet.member?(clay, {x, y}) -> "#"
            true -> " "
          end
        end
        |> Enum.join()

      IO.puts(device, string)
    end

    ground
  end
end
