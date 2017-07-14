defmodule Neko.UserRate.Store do
  @moduledoc """
  Stores user rates for one user.
  User rates are stored in Map with their ids as keys
  (so called keyed-by-id store).
  """

  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  def get(store, id) do
    Agent.get(store, &Map.get(&1, id))
  end

  # TODO: convert list of values to MapSet?
  def all(store) do
    Agent.get(store, &Map.values(&1))
  end

  def put(store, id, user_rate) do
    Agent.update(store, &Map.put(&1, id, user_rate))
  end

  # TODO: test
  def update(store, id, fields) do
    Agent.update(store, fn state ->
      Map.update!(state, id, &(struct(&1, fields)))
    end)
  end

  def set(store, user_rates) do
    new_state = Enum.reduce(user_rates, %{}, fn(x, acc) ->
      Map.put(acc, x.id, x)
    end)
    Agent.update(store, fn _ -> new_state end)
  end

  def delete(store, id) do
    Agent.get_and_update(store, &Map.pop(&1, id))
  end
end
