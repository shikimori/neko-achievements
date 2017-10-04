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
    |> calc_anime_ids()
    |> calc_thresholds()
    |> calc_next_thresholds()
  end

  defp calc_anime_ids(rules) do
    rules
    |> Enum.map(fn(x) -> %{x | anime_ids: anime_ids(x)} end)
  end

  defp anime_ids(%{filters: nil}) do
    Neko.Anime.all()
    |> Enum.map(&(&1.id))
    |> MapSet.new()
  end
  defp anime_ids(%{filters: %{"genre_ids" => genre_ids}})
  when is_nil(genre_ids) or map_size(genre_ids) == 0 do
    Neko.Anime.all()
    |> Enum.map(&(&1.id))
    |> MapSet.new()
  end
  defp anime_ids(%{filters: %{"genre_ids" => genre_ids}}) do
    Neko.Anime.all()
    |> Enum.filter(&lists_overlap?(&1.genre_ids, genre_ids))
    |> Enum.map(&(&1.id))
    |> MapSet.new()
  end

  defp lists_overlap?(list_1, list_2) do
    !Enum.empty?(list_1 -- (list_1 -- list_2))
  end

  defp calc_thresholds(rules) do
    rules
    |> Enum.map(fn
      %{threshold: threshold} = rule when is_integer(threshold) ->
        rule
      %{threshold: threshold} = rule when is_binary(threshold) ->
        %{rule | threshold: parse_threshold(rule)}
    end)
  end

  # when threshold is a string value, percent is implied
  defp parse_threshold(rule) do
    percent = rule.threshold |> Integer.parse() |> elem(0)
    MapSet.size(rule.anime_ids) * percent / 100
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
end
