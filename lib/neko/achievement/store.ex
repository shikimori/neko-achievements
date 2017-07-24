defmodule Neko.Achievement.Store do
  @moduledoc """
  Stores achievements for one user.
  User rates are stored in MapSet.
  """

  def start_link do
    Agent.start_link(fn -> %MapSet{} end)
  end

  def all(store) do
    Agent.get(store, &(&1))
  end

  def put(store, achievement) do
    Agent.update(store, &MapSet.put(&1, achievement))
  end

  def set(store, achievements) do
    Agent.update(store, fn _ -> MapSet.new(achievements) end)
  end

  def delete(store, achievement) do
    Agent.update(store, &MapSet.delete(&1, achievement))
  end
end
