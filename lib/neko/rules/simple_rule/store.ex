defmodule Neko.Rules.SimpleRule.Store do
  @algo "simple"

  def start_link(name \\ __MODULE__) do
    Agent.start_link(fn -> rules() end, name: name)
  end

  def reload(name \\ __MODULE__) do
    set(name, rules())
  end

  def all(name \\ __MODULE__) do
    Agent.get(name, &(&1))
  end

  def set(name \\ __MODULE__, rules) do
    Agent.update(name, fn _ -> rules end)
  end

  defp calc_anime_ids(rule) do
    %{rule | anime_ids: anime_ids(rule)}
  end

  defp anime_ids(%{filters: nil}) do
    Neko.Anime.all()
    |> Enum.map(&(&1.id))
    |> MapSet.new()
  end
  defp anime_ids(%{filters: filters}) do
    Neko.Anime.all()
    |> filter_by_genre_ids(filters["genre_ids"])
    |> filter_by_anime_ids(filters["anime_ids"])
    |> filter_by_year_lte(filters["year_lte"])
    |> Enum.map(&(&1.id))
    |> MapSet.new()
  end

  defp filter_by_genre_ids(animes, nil) do
    animes
  end
  defp filter_by_genre_ids(animes, genre_ids) do
    animes
    |> Enum.filter(&lists_overlap?(&1.genre_ids, genre_ids))
  end

  defp lists_overlap?(list_1, list_2) do
    !Enum.empty?(list_1 -- (list_1 -- list_2))
  end

  defp filter_by_anime_ids(animes, nil) do
    animes
  end
  defp filter_by_anime_ids(animes, anime_ids) do
    animes
    |> Enum.filter(&Enum.member?(anime_ids, &1.id))
  end

  defp filter_by_year_lte(animes, nil) do
    animes
  end
  defp filter_by_year_lte(animes, year_lte) do
    animes
    |> Enum.filter(&(&1.year && &1.year <= year_lte))
  end

  defp calc_threshold(%{threshold: threshold} = rule)
  when is_integer(threshold) do
    rule
  end
  defp calc_threshold(%{threshold: threshold} = rule)
  when is_binary(threshold) do
    %{rule | threshold: parse_threshold(rule)}
  end

  # when threshold is a string value, percent is implied
  defp parse_threshold(rule) do
    percent = rule.threshold |> Integer.parse() |> elem(0)
    MapSet.size(rule.anime_ids) * percent / 100 |> round()
  end

  # access to all rules is required to calculate
  # next threshold so iterate over rules here
  defp calc_next_thresholds(rules) do
    rules |> Enum.map(fn(x) ->
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

  defp rules do
    Neko.Rules.Reader.read_from_files(@algo)
    |> Enum.map(&Neko.Rules.SimpleRule.new/1)
    |> Enum.map(&calc_anime_ids/1)
    |> Enum.map(&calc_threshold/1)
    |> calc_next_thresholds()
  end
end
