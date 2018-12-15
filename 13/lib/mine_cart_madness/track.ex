defmodule MineCartMadness.Field do
  alias MineCartMadness.Cart

  defstruct track: %{}, carts: %{}

  def init(input) do
    {track, carts} =
      input
      |> String.split(~r/\n/, trim: true)
      |> Enum.with_index()
      |> Enum.reduce({%{}, %{}}, fn {line, y}, field ->
        line
        |> String.codepoints()
        |> Enum.with_index()
        |> Enum.reduce(field, fn
          {" ", _}, current_field ->
            current_field

          {"/", x}, {track, carts} ->
            {Map.put(track, {x, y}, :ad), carts}

          {"\\", x}, {track, carts} ->
            {Map.put(track, {x, y}, :deuce), carts}

          {"-", x}, {track, carts} ->
            {Map.put(track, {x, y}, :straight), carts}

          {"|", x}, {track, carts} ->
            {Map.put(track, {x, y}, :straight), carts}

          {"+", x}, {track, carts} ->
            {Map.put(track, {x, y}, :cross), carts}

          {">", x}, {track, carts} ->
            {Map.put(track, {x, y}, :straight), Map.put(carts, {x, y}, %Cart{dxn: :east})}

          {"<", x}, {track, carts} ->
            {Map.put(track, {x, y}, :straight), Map.put(carts, {x, y}, %Cart{dxn: :west})}

          {"v", x}, {track, carts} ->
            {Map.put(track, {x, y}, :straight), Map.put(carts, {x, y}, %Cart{dxn: :south})}

          {"^", x}, {track, carts} ->
            {Map.put(track, {x, y}, :straight), Map.put(carts, {x, y}, %Cart{dxn: :north})}
        end)
      end)

    %__MODULE__{track: track, carts: carts}
  end

  def first_crash_location(%__MODULE__{} = field) do
    keep_ticking(field, &first_crash_location_tick/1)
  end

  def last_cart_location(%__MODULE__{} = field) do
    keep_ticking(field, &last_cart_location_tick/1)
  end

  defp keep_ticking(%__MODULE__{} = field, fun) do
    case fun.(field) do
      {:tock, new_field} -> keep_ticking(new_field, fun)
      res -> res
    end
  end

  defp first_crash_location_tick(%__MODULE__{} = field) do
    new_carts_or_crash =
      reduce_carts_while(field.carts, field.track, fn coords, _ -> {:halt, {:crash, coords}} end)

    case new_carts_or_crash do
      {:crash, coords} -> coords
      new_carts -> {:tock, %__MODULE__{field | carts: new_carts}}
    end
  end

  defp last_cart_location_tick(%__MODULE__{} = field) do
    new_carts = reduce_carts_while(field.carts, field.track, fn _, carts -> {:cont, carts} end)

    case map_size(new_carts) do
      1 -> with [{coords, _}] = Enum.to_list(new_carts), do: coords
      0 -> nil
      _ -> {:tock, %__MODULE__{field | carts: new_carts}}
    end
  end

  defp reduce_carts_while(carts, track, handle_crash) do
    Enum.reduce_while(
      carts,
      %{},
      fn {cur_coords, %Cart{dxn: cur_dxn} = cart}, new_carts ->
        case Map.pop(new_carts, cur_coords) do
          {nil, _} ->
            new_coords = move(cur_coords, cur_dxn)

            case Map.pop(new_carts, new_coords) do
              {nil, _} ->
                rail = Map.get(track, new_coords)
                new_cart = Cart.orient(cart, rail)
                {:cont, Map.put(new_carts, new_coords, new_cart)}

              {_, surviving_carts} ->
                handle_crash.(new_coords, surviving_carts)
            end

          {_, surviving_carts} ->
            handle_crash.(cur_coords, surviving_carts)
        end
      end
    )
  end

  defp move({x, y}, :north), do: {x, y - 1}
  defp move({x, y}, :east), do: {x + 1, y}
  defp move({x, y}, :south), do: {x, y + 1}
  defp move({x, y}, :west), do: {x - 1, y}
end
