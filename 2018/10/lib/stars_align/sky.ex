defmodule StarsAlign.Sky do
  def stargaze(sky, seconds \\ 0, past_meaning \\ :inf) do
    new_sky = appreciate_another_second(sky)

    case be_hopeful(new_sky, past_meaning) do
      {true, new_meaning} ->
        stargaze(new_sky, seconds + 1, new_meaning)

      false ->
        amaze_the_dreamer(sky)
        {seconds, past_meaning}
    end
  end

  def appreciate_another_second(sky) do
    Enum.map(sky, fn {{x, y}, {vel_x, vel_y} = vel} -> {{x + vel_x, y + vel_y}, vel} end)
  end

  defp be_hopeful(sky, :inf) do
    {true, make_sense(sky)}
  end

  defp be_hopeful(sky, past_meaning) do
    current_meaning = make_sense(sky)

    if current_meaning <= past_meaning do
      {true, current_meaning}
    else
      false
    end
  end

  defp make_sense(sky) do
    {{{_, min_y}, _}, {{_, max_y}, _}} = Enum.min_max_by(sky, fn {{_, y}, _} -> y end)

    max_y - min_y
  end

  defp amaze_the_dreamer(sky) do
    {{{min_x, _}, _}, {{max_x, _}, _}} = Enum.min_max_by(sky, fn {{x, _}, _} -> x end)

    sky
    |> Enum.map(&elem(&1, 0))
    |> Enum.group_by(
      fn {_, y} -> y end,
      fn {x, _} -> x end
    )
    |> Enum.map(fn {_, points} ->
      set = MapSet.new(points)
      Enum.join(for old_x <- min_x..max_x, do: if(MapSet.member?(set, old_x), do: "#", else: " "))
    end)
    |> Enum.each(&IO.puts/1)
  end
end
