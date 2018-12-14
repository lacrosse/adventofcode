defmodule MineCartMadness.Field do
  alias MineCartMadness.Cart

  defstruct track: %{}, carts: %{}

  def init(input) do
    {track, carts} =
      input
      |> String.split(~r/\n/, trim: true)
      |> Enum.with_index()
      |> Enum.reduce({%{}, %{}}, fn {line, y}, acc ->
        line
        |> String.codepoints()
        |> Enum.with_index()
        |> Enum.reject(fn {object, _} -> object == " " end)
        |> Enum.reduce(acc, fn
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
    case tick(field) do
      {:ok, field} ->
        first_crash_location(field)

      {:crash, location} ->
        location
    end
  end

  defp tick(%__MODULE__{track: track, carts: carts} = field) do
    new_carts_or_crash =
      carts
      |> Enum.reduce_while(
        %{},
        fn
          {{cur_x, cur_y} = cur_coords, %Cart{dxn: cur_dxn} = cart}, new_carts ->
            if Map.get(new_carts, cur_coords) do
              {:halt, {:crash, cur_coords}}
            else
              new_coords =
                case cur_dxn do
                  :north -> {cur_x, cur_y - 1}
                  :east -> {cur_x + 1, cur_y}
                  :south -> {cur_x, cur_y + 1}
                  :west -> {cur_x - 1, cur_y}
                end

              if Map.get(new_carts, new_coords) do
                {:halt, {:crash, new_coords}}
              else
                {:cont,
                 Map.put(new_carts, new_coords, Cart.orient(cart, Map.get(track, new_coords)))}
              end
            end
        end
      )

    case new_carts_or_crash do
      {:crash, _} -> new_carts_or_crash
      new_carts -> {:ok, %__MODULE__{field | carts: new_carts}}
    end
  end
end
