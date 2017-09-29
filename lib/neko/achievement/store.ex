defmodule Neko.Achievement.Store do
  # store achievements in MapSet because they are dynamically updated
  def start_link do
    Agent.start_link(fn -> MapSet.new() end)
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
