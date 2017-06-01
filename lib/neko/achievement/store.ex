defmodule Neko.Achievement.Store do
  @moduledoc """
  Stores achievements by their ids for single user.
  """

  def start_link do
    Agent.start_link(fn -> %{} end)
  end

  def get store, id do
    Agent.get(store, &Map.get(&1, id))
  end

  def put store, id, achievement do
    Agent.update(store, &Map.put(&1, id, achievement))
  end

  def delete store, id do
    Agent.get_and_update(store, &Map.pop(&1, id))
  end
end
