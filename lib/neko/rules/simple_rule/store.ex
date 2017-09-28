defmodule Neko.Rules.SimpleRule.Store do
  @algo "simple"

  def start_link(name \\ __MODULE__) do
    Agent.start_link(fn -> load() end, name: name)
  end

  def all(name \\ __MODULE__) do
    Agent.get(name, &(&1))
  end

  def load do
    Neko.Rules.Reader.read_from_files(@algo)
    |> Enum.map(&(Neko.Rules.SimpleRule.new(&1)))
    |> calc_next_thresholds()
    |> calc_anime_ids()
  end

  defp calc_next_thresholds(rules) do
    rules
    |> Enum.map(fn(x) ->
      %{x | next_threshold: next_threshold(rules, x)}
    end)
  end

  defp next_threshold(rules, rule) do
    rules
    |> Enum.filter(fn(x) ->
      x.neko_id == rule.neko_id and x.level == rule.level + 1
    end)
    |> Enum.map(&(&1.threshold))
    |> List.first()
  end

  defp calc_anime_ids(rules) do
    rules
    |> Enum.map(fn(x) ->
      %{x | anime_ids: anime_ids(rules, x)}
    end)
  end

  defp anime_ids(rule) do
    # TODO: return MapSet
  end
end
