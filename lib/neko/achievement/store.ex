defmodule Neko.Achievement.Store do
  @moduledoc """
  Stores achievements by their neko ids for single user.
  """

  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  def get store, neko_id do
    Agent.get(store, &Map.get(&1, neko_id))
  end

  def put store, neko_id, achievement do
    Agent.update(store, &Map.put(&1, neko_id, achievement))
  end

  def delete store, neko_id do
    Agent.get_and_update(store, &Map.pop(&1, neko_id))
  end
end
