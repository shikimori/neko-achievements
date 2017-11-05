defmodule Neko.Rules.SimpleRule.Store do
  @algo "simple"
  @rules_reader Application.get_env(:neko, :rules)[:reader]

  def start_link(name \\ __MODULE__) do
    Agent.start_link(
      fn -> rules() |> calc() end,
      name: name
    )
  end

  def reload(name \\ __MODULE__) do
    Agent.update(
      name,
      fn _ -> rules() |> calc() end
    )
  end

  def all(name \\ __MODULE__) do
    Agent.get(name, &(&1))
  end

  def set(name \\ __MODULE__, rules) do
    Agent.update(
      name,
      fn _ -> rules |> calc() end
    )
  end

  defp calc(rules) do
    rules
    |> Enum.map(&calc_anime_ids/1)
    |> Enum.map(&calc_threshold/1)
    |> calc_next_thresholds()
  end

  defp calc_anime_ids(rule) do
    anime_ids = Neko.Anime.all() |> anime_ids(rule)
    %{rule | anime_ids: anime_ids}
  end

  defp anime_ids([], _rule) do
    MapSet.new()
  end
  defp anime_ids(all_animes, %{filters: nil}) do
    all_animes
    |> Enum.map(&(&1.id))
    |> MapSet.new()
  end
  defp anime_ids(all_animes, %{filters: filters}) do
    all_animes
    |> filter_by_genre_ids(filters["genre_ids"])
    |> filter_by_anime_ids(filters["anime_ids"])
    |> filter_by_year_lte(filters["year_lte"])
    |> filter_by_episodes_gte(filters["episodes_gte"])
    |> Enum.map(&(&1.id))
    |> MapSet.new()
  end

  # TODO: replace animes and genre_ids with mapsets
  #       and rewrite lists_overlap with genre_ids_overlap?
  # TODO: don't store user rates in map?
  defp filter_by_genre_ids(animes, nil) do
    animes
  end
  defp filter_by_genre_ids(animes, genre_ids) do
    animes
    |> Enum.reject(&is_nil(&1.genre_ids))
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
    |> Enum.reject(&is_nil(&1.year))
    |> Enum.filter(&(&1.year <= year_lte))
  end

  defp filter_by_episodes_gte(animes, nil) do
    animes
  end
  defp filter_by_episodes_gte(animes, episodes_gte) do
    animes
    |> Enum.reject(&is_nil(&1.episodes))
    |> Enum.filter(&(&1.episodes >= episodes_gte))
  end

  defp calc_threshold(%{threshold: threshold} = rule)
  when is_number(threshold) do
    rule
  end
  defp calc_threshold(%{threshold: threshold} = rule)
  when is_binary(threshold) do
    %{rule | threshold: parse_threshold(rule)}
  end

  # when threshold is a string value, percent is implied
  defp parse_threshold(rule) do
    percent = rule.threshold |> Float.parse() |> elem(0)
    MapSet.size(rule.anime_ids) * percent / 100 |> Float.round(2)
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
    @rules_reader.read_rules(@algo)
  end
end
