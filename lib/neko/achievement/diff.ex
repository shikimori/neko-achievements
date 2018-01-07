# https://stackoverflow.com/questions/36345425
defmodule Neko.Achievement.Diff do
  @moduledoc false

  def call(old_achievements, new_achievements) do
    keyed_old_achievements = keyed_achievements(old_achievements)
    keyed_new_achievements = keyed_achievements(new_achievements)

    %{
      added: added_achievements(
        keyed_old_achievements,
        keyed_new_achievements
      ),
      removed: removed_achievements(
        keyed_old_achievements,
        keyed_new_achievements
      ),
      updated: updated_achievements(
        keyed_old_achievements,
        keyed_new_achievements
      )
    }
  end

  defp keyed_achievements(achievements) do
    Enum.reduce(achievements, %{}, fn(x, acc) ->
      Map.put(acc, comparison_key(x), x)
    end)
  end

  defp comparison_key(achievement) do
    achievement
    |> Map.take([:neko_id, :level])
    |> Map.values()
    |> List.to_tuple()
  end

  defp added_achievements(keyed_old_achievements, keyed_new_achievements) do
    keyed_new_achievements
    |> Map.drop(Map.keys(keyed_old_achievements))
    |> Map.values()
    |> MapSet.new()
  end

  defp removed_achievements(keyed_old_achievements, keyed_new_achievements) do
    keyed_old_achievements
    |> Map.drop(Map.keys(keyed_new_achievements))
    |> Map.values()
    |> MapSet.new()
  end

  defp updated_achievements(keyed_old_achievements, keyed_new_achievements) do
    not_removed_old_achievements =
      keyed_old_achievements
      |> Map.take(Map.keys(keyed_new_achievements))
      |> Map.values()
      |> MapSet.new()

    not_added_new_achievements =
      keyed_new_achievements
      |> Map.take(Map.keys(keyed_old_achievements))
      |> Map.values()
      |> MapSet.new()

    MapSet.difference(not_added_new_achievements, not_removed_old_achievements)
  end
end
