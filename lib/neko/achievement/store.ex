defmodule Neko.Achievement.Store do
  alias Neko.Achievement.Store.Registry

  def start_link do
    Agent.start_link(fn -> MapSet.new() end)
  end

  # for reload/1 store is identified not by pid but
  # by user_id since we need it to fetch achievements
  #
  # it also creates store for user_id if it's missing
  # (unlike reload/1 in, say, Neko.Anime.Store)
  def reload(user_id) do
    achievements = achievements(user_id)
    Registry.fetch(user_id) |> set(achievements)
  end

  def all(pid) do
    Agent.get(pid, &(&1))
  end

  def put(pid, achievement) do
    Agent.update(pid, &MapSet.put(&1, achievement))
  end

  def set(pid, achievements) do
    Agent.update(pid, fn _ -> MapSet.new(achievements) end)
  end

  def delete(pid, achievement) do
    Agent.update(pid, &MapSet.delete(&1, achievement))
  end

  defp achievements(user_id) do
    Neko.Shikimori.Client.get_achievements!(user_id)
  end
end
