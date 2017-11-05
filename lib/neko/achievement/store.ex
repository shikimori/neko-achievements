defmodule Neko.Achievement.Store do
  def start_link do
    Agent.start_link(fn -> MapSet.new() end)
  end

  # fetch achievements in server callback so
  # that agent dies in case of fetching error
  def reload(pid, user_id) do
    Agent.update(pid, fn _ ->
      achievements(user_id)
      |> MapSet.new()
    end)
  end

  def all(pid) do
    Agent.get(pid, &(&1))
  end

  def put(pid, achievement) do
    Agent.update(pid, &MapSet.put(&1, achievement))
  end

  def set(pid, achievements) do
    Agent.update(pid, fn _ -> achievements end)
  end

  def delete(pid, achievement) do
    Agent.update(pid, &MapSet.delete(&1, achievement))
  end

  defp achievements(user_id) do
    Neko.Shikimori.Client.get_achievements!(user_id)
  end
end
