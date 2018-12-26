defmodule Neko.UserRate.Store do
  use Agent, restart: :temporary

  @type user_rate_t :: Neko.UserRate.t()
  @type user_rates_t :: %{pos_integer => user_rate_t}

  # add timeout to Agent calls that perform network requests only
  @call_timeout Application.get_env(:neko, :shikimori)[:total_timeout]

  @spec start_link(any) :: Agent.on_start()
  def start_link(_) do
    Agent.start_link(fn -> %{} end)
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
    Agent.update(pid, &Map.put(&1, user_rate.id, user_rate))
  end

  @spec set(pid, [user_rate_t]) :: :ok
  def set(pid, user_rates) do
    Agent.update(pid, fn _ -> reduce_to_map(user_rates) end)
  end

  @spec delete(pid, user_rate_t) :: :ok
  def delete(pid, user_rate) do
    Agent.update(pid, fn user_rates ->
      Map.delete(user_rates, user_rate.id)
    end)
  end

  @spec user_rates(pos_integer) :: user_rates_t
  defp user_rates(user_id) do
    user_id
    |> Neko.Shikimori.Client.get_user_rates!()
    |> reduce_to_map
  end

  @spec reduce_to_map([user_rate_t]) :: user_rates_t
  defp reduce_to_map(user_rates) do
    Enum.reduce(user_rates, %{}, fn x, acc ->
      Map.put(acc, x.id, x)
    end)
  end
end
