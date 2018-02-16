defmodule Neko.UserRate.Store do
  @moduledoc false

  @type user_rate_t :: %Neko.UserRate{}
  @type user_rates_t :: MapSet.t(user_rate_t)

  # add timeout to Agent calls that perform network requests only
  @call_timeout Application.get_env(:neko, :shikimori)[:recv_timeout]

  @spec start_link :: Agent.on_start()
  def start_link do
    Agent.start_link(fn -> MapSet.new() end)
  end

  @spec stop(pid) :: :ok
  def stop(pid) do
    Agent.stop(pid)
  end

  @spec reload(pid, pos_integer) :: :ok
  def reload(pid, user_id) do
    Agent.update(
      pid,
      fn _ -> user_rates(user_id) end,
      @call_timeout
    )
  end

  @spec all(pid) :: user_rates_t
  def all(pid) do
    Agent.get(pid, & &1)
  end

  @spec put(pid, user_rate_t) :: :ok
  def put(pid, user_rate) do
    Agent.update(pid, &MapSet.put(&1, user_rate))
  end

  @spec set(pid, user_rates_t) :: :ok
  def set(pid, user_rates) do
    Agent.update(pid, fn _ -> user_rates end)
  end

  @spec delete(pid, user_rate_t) :: :ok
  def delete(pid, user_rate) do
    Agent.update(pid, &MapSet.delete(&1, user_rate))
  end

  @spec user_rates(pos_integer) :: user_rates_t
  defp user_rates(user_id) do
    user_id
    |> Neko.Shikimori.Client.get_user_rates!()
    |> MapSet.new()
  end
end
