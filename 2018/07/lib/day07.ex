defmodule Day07 do
  @command_regex ~r/\AStep (\w) must be finished before step (\w) can begin.\z/

  def solve do
    dependency_map =
      'input.txt'
      |> File.read!()
      |> create_dependency_map()

    first =
      dependency_map
      |> create_order_from_dependency_map()

    second =
      dependency_map
      |> execution_time_with_workers(5)

    {first, second}
  end

  defp create_dependency_map(text_commands) do
    text_commands
    |> String.split(~r/\n/, trim: true)
    |> Enum.map(fn str ->
      [[from], [to]] =
        Regex.run(@command_regex, str, capture: :all_but_first)
        |> Enum.map(&String.to_charlist/1)

      {from, to}
    end)
    |> group_commands()
  end

  @doc """
      iex> [
      ...>   "Step C must be finished before step A can begin.",
      ...>   "Step C must be finished before step F can begin.",
      ...>   "Step A must be finished before step B can begin.",
      ...>   "Step A must be finished before step D can begin.",
      ...>   "Step B must be finished before step E can begin.",
      ...>   "Step D must be finished before step E can begin.",
      ...>   "Step F must be finished before step E can begin."
      ...> ] |> Enum.map(& &1 <> "\\n") |> Enum.join() |> Day07.order_text_commands()
      "CABDFE"
  """
  def order_text_commands(text_commands) do
    text_commands
    |> create_dependency_map()
    |> create_order_from_dependency_map()
  end

  defp group_commands(commands) do
    primitive_groups =
      commands
      |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))

    commands
    |> Enum.map(&elem(&1, 0))
    |> Enum.reduce(primitive_groups, &Map.put_new(&2, &1, []))
    |> Enum.map(fn {to, froms_list} ->
      {to, Enum.into(froms_list, MapSet.new())}
    end)
    |> Enum.into(%{})
  end

  defp create_order_from_dependency_map(dependency_map, acc \\ [])

  defp create_order_from_dependency_map(dependency_map, acc) when dependency_map == %{} do
    acc
    |> Enum.reverse()
    |> to_string()
  end

  defp create_order_from_dependency_map(dependency_map, acc) when is_map(dependency_map) do
    with {node, new_dependency_map} = extract_root(dependency_map),
      do: create_order_from_dependency_map(new_dependency_map, [node | acc])
  end

  defp find_task(deps) do
    branches =
      deps
      |> Enum.filter(fn
        {_, froms} when froms == %MapSet{} -> true
        _ -> false
      end)

    case branches do
      [] ->
        nil

      list ->
        with {task, _} = Enum.min_by(list, &elem(&1, 0)),
          do: task
    end
  end

  defp start_task(deps, task) do
    Map.drop(deps, [task])
  end

  defp finish_task(deps, task) do
    deps
    |> Enum.map(fn {to, froms} -> {to, MapSet.delete(froms, task)} end)
    |> Enum.into(%{})
  end

  defp extract_root(dependency_map) do
    task = find_task(dependency_map)

    new_dependency_map =
      dependency_map
      |> start_task(task)
      |> finish_task(task)

    {task, new_dependency_map}
  end

  defp execution_time_with_workers(deps, num_of_workers) do
    workers = for _ <- 1..num_of_workers, do: nil

    do_execution_time_with_workers(deps, workers, 0)
  end

  defp do_execution_time_with_workers(deps, workers, elapsed) do
    {worked_workers, worked_deps} = Enum.map_reduce(workers, deps, &work_worker/2)
    {loaded_workers, loaded_deps} = Enum.map_reduce(worked_workers, worked_deps, &load_worker/2)

    if Enum.any?(loaded_workers) do
      do_execution_time_with_workers(loaded_deps, loaded_workers, elapsed + 1)
    else
      elapsed
    end
  end

  defp work_worker(nil, deps), do: {nil, deps}
  defp work_worker({task, time}, deps) when time > 0, do: {{task, time - 1}, deps}
  defp work_worker({task, 0}, deps), do: {nil, finish_task(deps, task)}

  defp load_worker(nil, deps) do
    case find_task(deps) do
      nil -> {nil, deps}
      task -> {{task, calculate_time(task)}, start_task(deps, task)}
    end
  end

  defp load_worker(worker, deps), do: {worker, deps}

  defp calculate_time(task), do: task - ?A + 60
end
