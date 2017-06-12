defmodule Neko.UserRate.Store do
  @moduledoc """
  Stores user rates by their ids for single user.
  """

  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  def get store, id do
    Agent.get(store, &Map.get(&1, id))
  end

  def put store, id, user_rate do
    Agent.update(store, &Map.put(&1, id, user_rate))
  end

  def delete store, id do
    Agent.get_and_update(store, &Map.pop(&1, id))
  end
end
