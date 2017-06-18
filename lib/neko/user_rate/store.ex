defmodule Neko.UserRate.Store do
  @moduledoc """
  Stores user rates for one user.
  User rates are stored in Map with their ids as keys.
  """

  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  # TODO: convert list of values to set
  #       for the sake of performance?
  def all(store) do
    Agent.get(store, &Map.values(&1))
  end

  def get(store, id) do
    Agent.get(store, &Map.get(&1, id))
  end

  def put(store, id, user_rate) do
    Agent.update(store, &Map.put(&1, id, user_rate))
  end

  def delete(store, id) do
    Agent.get_and_update(store, &Map.pop(&1, id))
  end
end
