defmodule Neko.Achievement.Store do
  @type achievement_t :: %Neko.Achievement{}
  @type achievements_t :: MapSet.t(achievement_t)

  @spec start_link :: Agent.on_start
  def start_link do
    Agent.start_link(fn -> MapSet.new() end)
  end

  # fetch achievements in server callback so
  # that agent dies in case of fetching error
  @spec reload(pid, pos_integer) :: :ok
  def reload(pid, user_id) do
    Agent.update(pid, fn(_) -> achievements(user_id) end)
  end

  @spec all(pid) :: achievements_t
  def all(pid) do
    Agent.get(pid, &(&1))
  end

  @spec set(pid, achievements_t) :: :ok
  def set(pid, achievements) do
    Agent.update(pid, fn(_) -> achievements end)
  end

  @spec achievements(pos_integer) :: achievements_t
  defp achievements(user_id) do
    Neko.Shikimori.Client.get_achievements!(user_id)
    |> MapSet.new()
  end
end
