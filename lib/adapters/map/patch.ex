defmodule ExAudit.Adapters.Map.Patch do
  @behaviour ExAudit.Adapters.PatchAdapter

  @doc """
  Applies the patch to the given term
  """
  def patch(_, %{changed: :primitive_change, added: b, removed: _a}) do
    b
  end

  def patch(a, :not_changed) do
    a
  end

  def patch(list, changes) when is_list(list) and is_list(changes) do
    changes
    |> Enum.reverse()
    |> Enum.reduce(list, fn
      %{added: el}, map ->
        List.insert_at(map, -1, el)

      %{removed: el}, map ->
        List.delete(map, el)

      %{changed: :added_to_list, index: i, added: el}, list ->
        List.insert_at(list, i, el)

      %{changed: :removed_from_list, index: i, removed: _}, list ->
        List.delete_at(list, i)

      %{changed: :changed_in_list, index: i, changes: change}, list ->
        List.update_at(list, i, &patch(&1, change))
    end)
  end

  def patch(map, changes) when is_map(map) and is_map(changes) do
    changes
    |> Enum.reduce(map, fn
      {key, %{added: b}}, map ->
        Map.put(map, key, b)

      {key, %{changed: :added, added: b}}, map ->
        Map.put(map, key, b)

      {key, %{removed: _}}, map ->
        Map.delete(map, key)

      {key, %{changed: :removed, removed: _}}, map ->
        Map.delete(map, key)

      {key, %{changed: changes}}, map ->
        Map.update!(map, key, &patch(&1, changes))
    end)
  end
end
