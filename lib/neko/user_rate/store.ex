defmodule Neko.UserRate.Store do
  @moduledoc """
  Stores user rates for one user.
  User rates are stored in Map with their ids as keys
  (so called keyed-by-id store).
  """

  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  def stop(pid) do
    Agent.stop(pid)
  end

  def get(pid, id) do
    Agent.get(pid, &Map.get(&1, id))
  end

  def all(pid) do
    Agent.get(pid, fn(state) ->
      state
      |> Map.values()
      |> MapSet.new()
    end)
  end

  def put(pid, id, user_rate) do
    Agent.update(pid, &Map.put(&1, id, user_rate))
  end

  def set(pid, user_rates) do
    Agent.update(pid, fn _ ->
      Enum.reduce(user_rates, %{}, fn(x, acc) ->
        Map.put(acc, x.id, x)
      end)
    end)
  end

  def update(pid, id, fields) do
    Agent.update(pid, fn state ->
      Map.update!(state, id, &(struct(&1, fields)))
    end)
  end

  def delete(pid, id) do
    Agent.get_and_update(pid, &Map.pop(&1, id))
  end
end
