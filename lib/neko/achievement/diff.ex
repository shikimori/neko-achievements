# https://stackoverflow.com/questions/36345425
defmodule Neko.Achievement.Diff do
  def call(old_achievements, new_achievements) do
    keyed_old_set = keyed_set(old_achievements)
    keyed_new_set = keyed_set(new_achievements)

    %{
      added: added_achievements(keyed_old_set, keyed_new_set),
      removed: removed_achievements(keyed_old_set, keyed_new_set),
      updated: updated_achievements(keyed_old_set, keyed_new_set)
    }
  end

  defp keyed_set(set) do
    Enum.reduce(set, %{}, fn(x, acc) ->
      Map.put_new(acc, comparison_key(x), x)
    end)
  end

  # TODO: remove List.to_tuple()?
  defp comparison_key(achievement) do
    achievement
    |> Map.take([:neko_id, :level])
    |> Map.values()
    |> List.to_tuple()
  end

  defp added_achievements(keyed_old_set, keyed_new_set) do
    keyed_new_set
    |> Map.drop(Map.keys(keyed_old_set))
    |> Map.values()
    |> MapSet.new()
  end

  defp removed_achievements(keyed_old_set, keyed_new_set) do
    keyed_old_set
    |> Map.drop(Map.keys(keyed_new_set))
    |> Map.values()
    |> MapSet.new()
  end

  defp updated_achievements(keyed_old_set, keyed_new_set) do
    not_removed_old_achievements =
      keyed_old_set
      |> Map.take(Map.keys(keyed_new_set))
      |> Map.values()
      |> MapSet.new()

    not_added_new_achievements =
      keyed_new_set
      |> Map.take(Map.keys(keyed_old_set))
      |> Map.values()
      |> MapSet.new()

    MapSet.difference(
      not_added_new_achievements,
      not_removed_old_achievements
    )
  end
end
