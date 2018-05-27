defmodule Neko.Achievement.Store do
  @moduledoc false

  use Agent, restart: :temporary

  @type achievement_t :: Neko.Achievement.t()
  @type achievements_t :: MapSet.t(achievement_t)

  # add timeout to Agent calls that perform network requests only
  @call_timeout Application.get_env(:neko, :shikimori)[:total_timeout]

  @spec start_link(any) :: Agent.on_start()
  def start_link(_) do
    Agent.start_link(fn -> MapSet.new() end)
  end

  @spec stop(pid) :: :ok
  def stop(pid) do
    Agent.stop(pid)
  end

  # fetch achievements in server callback so
  # that agent dies in case of fetching error
  @spec reload(pid, pos_integer) :: :ok
  def reload(pid, user_id) do
    Agent.update(
      pid,
      fn _ -> achievements(user_id) end,
      @call_timeout
    )
  end

  @spec all(pid) :: achievements_t
  def all(pid) do
    Agent.get(pid, & &1)
  end

  @spec set(pid, [achievement_t]) :: :ok
  def set(pid, achievements) when is_list(achievements) do
    set(pid, MapSet.new(achievements))
  end

  @spec set(pid, achievements_t) :: :ok
  def set(pid, achievements) do
    Agent.update(pid, fn _ -> achievements end)
  end

  @spec achievements(pos_integer()) :: achievements_t
  defp achievements(user_id) do
    user_id
    |> Neko.Shikimori.Client.get_achievements!()
    |> MapSet.new()
  end
end
