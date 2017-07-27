defmodule Neko.Rules.BasicRule.Store do
  @moduledoc """
  Stores rules.
  """

  @rule_type "basic"

  def start_link(name \\ __MODULE__) do
    Agent.start_link(fn -> load() end, name: name)
  end

  def all(name \\ __MODULE__) do
    Agent.get(name, &(&1))
  end

  # TODO: add next_threshold to BasicRule -
  #       calculate it dynamically by searching
  #       rule with the same neko_id and next level
  defp load do
    Neko.Rules.Reader.read_from_file(@rule_type)
    |> Enum.map(&(Neko.Rules.BasicRule.new(&1)))
  end
end
