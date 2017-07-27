defmodule Neko.Achievement.Store do
  @moduledoc """
  Stores achievements for one user.
  User rates are stored in MapSet.
  """

  def start_link do
    Agent.start_link(fn -> %MapSet{} end)
  end

  def all(pid) do
    Agent.get(pid, &(&1))
  end

  def put(pid, achievement) do
    Agent.update(pid, &MapSet.put(&1, achievement))
  end

  def set(pid, achievements) do
    Agent.update(pid, fn _ -> MapSet.new(achievements) end)
  end

  def delete(pid, achievement) do
    Agent.update(pid, &MapSet.delete(&1, achievement))
  end
end
