defmodule Day08.Tree do
  defstruct children: [], metadata: []

  def from_definition(definition) do
    {tree, []} = from_definition_with_tail(definition)

    tree
  end

  def sum_metadata(%__MODULE__{children: children, metadata: metadata}) do
    Enum.sum(metadata ++ Enum.map(children, &sum_metadata/1))
  end

  def value(%__MODULE__{children: []} = tree), do: sum_metadata(tree)

  def value(%__MODULE__{children: children, metadata: metadata}) do
    metadata
    |> Enum.map(&Enum.at(children, &1 - 1))
    |> Enum.filter(& &1)
    |> Enum.map(&value/1)
    |> Enum.sum()
  end

  defp from_definition_with_tail([children_count, meta_count | definition_tail]) do
    {children_count, meta_count, definition_tail}

    {children, new_tail} = children_from_definition_with_tail(definition_tail, children_count)

    {metadata, new_tail} = Enum.split(new_tail, meta_count)

    {%__MODULE__{children: children, metadata: metadata}, new_tail}
  end

  defp children_from_definition_with_tail(definition, count, children \\ [])

  defp children_from_definition_with_tail(definition, 0, children) do
    {Enum.reverse(children), definition}
  end

  defp children_from_definition_with_tail(definition, count, children) do
    {child, tail} = from_definition_with_tail(definition)

    children_from_definition_with_tail(tail, count - 1, [child | children])
  end
end
