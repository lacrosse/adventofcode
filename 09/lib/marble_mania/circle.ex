defmodule MarbleMania.Circle do
  defstruct list: %{}, current: nil

  @doc """
    iex> circle = %MarbleMania.Circle{list: %{0 => {1, 1}, 1 => {0, 0}}, current: 1}
    iex> MarbleMania.Circle.remove(circle, -3)
    {0, %MarbleMania.Circle{list: %{1 => {1, 1}}, current: 1}}
  """
  def remove(circle, index) do
    circle
    |> rotate(index)
    |> pop()
  end

  @doc """
    iex> circle = %MarbleMania.Circle{list: %{0 => {1, 1}, 1 => {0, 0}}, current: 1}
    iex> MarbleMania.Circle.insert(circle, 2)
    %MarbleMania.Circle{current: 2, list: %{0 => {1, 2}, 1 => {2, 0}, 2 => {0, 1}}}
  """
  def insert(%__MODULE__{} = circle, item) do
    circle
    |> rotate(2)
    |> push(item)
  end

  defp rotate(%__MODULE__{} = circle, 0), do: circle

  defp rotate(%__MODULE__{} = circle, n) when n < 0 do
    {new_current, _} = Map.get(circle.list, circle.current)
    rotate(%__MODULE__{circle | current: new_current}, n + 1)
  end

  defp rotate(%__MODULE__{} = circle, n) when n > 0 do
    {_, new_current} = Map.get(circle.list, circle.current)
    rotate(%__MODULE__{circle | current: new_current}, n - 1)
  end

  defp pop(%__MODULE__{} = circle) do
    {{left, right}, new_list} = Map.pop(circle.list, circle.current)

    new_list =
      new_list
      |> Map.update(left, nil, fn {left_of_left, _} -> {left_of_left, right} end)
      |> Map.update(right, nil, fn {_, right_of_right} -> {left, right_of_right} end)

    {circle.current, %__MODULE__{circle | list: new_list, current: right}}
  end

  defp push(%__MODULE__{} = circle, item) do
    {old_left, new_list} =
      Map.get_and_update!(circle.list, circle.current, fn {old_left, old_right} ->
        {old_left, {item, old_right}}
      end)

    new_list =
      new_list
      |> Map.update(old_left, nil, fn {left_of_left, _} -> {left_of_left, item} end)
      |> Map.put(item, {old_left, circle.current})

    %__MODULE__{circle | list: new_list, current: item}
  end
end
