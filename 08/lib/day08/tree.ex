defmodule Day08.Tree do
  defstruct children: [], metadata: []

  def from_definition(definition) do
    {tree, []} = from_definition_with_tail(definition)

    tree
  end

  def from_definition_with_tail([children_count, meta_count | definition_tail]) do
    {children_count, meta_count, definition_tail}

    {children, new_tail} = children_from_definition_with_tail(definition_tail, children_count)

    {metadata, new_tail} = Enum.split(new_tail, meta_count)

    {%Day08.Tree{children: children, metadata: metadata}, new_tail}
  end

  def sum_metadata(%Day08.Tree{children: children, metadata: metadata}) do
    Enum.sum(metadata ++ Enum.map(children, &sum_metadata/1))
  end

  defp children_from_definition_with_tail(definition, count, children \\ [])

  defp children_from_definition_with_tail(definition, 0, children) do
    {Enum.reverse(children), definition}
  end

  defp children_from_definition_with_tail([], count, _) when count > 0 do
    raise("no more defs but #{count} required")
  end

  defp children_from_definition_with_tail(definition, count, children) do
    {child, tail} = from_definition_with_tail(definition)

    children_from_definition_with_tail(tail, count - 1, [child | children])
  end
end
