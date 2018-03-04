defmodule Neko.Rules.SimpleRule.Store do
  @moduledoc false

  use Agent

  @type rule_t :: %Neko.Rules.SimpleRule{}
  @type rules_t :: MapSet.t(rule_t)

  @name __MODULE__
  @algo "simple"
  @rules_reader Application.get_env(:neko, :rules)[:reader]

  @spec start_link(any) :: Agent.on_start()
  def start_link(_) do
    Agent.start_link(fn -> rules() |> calc() end, name: @name)
  end

  @spec reload() :: :ok
  def reload do
    Agent.update(@name, fn _ -> rules() |> calc() end)
  end

  @spec all() :: rules_t
  def all do
    Agent.get(@name, & &1)
  end

  @spec set(rules_t) :: :ok
  def set(rules) do
    Agent.update(@name, fn _ -> rules |> calc() end)
  end

  @spec calc(rules_t) :: rules_t
  defp calc(rules) do
    rules
    |> Enum.map(&calc_anime_ids/1)
    |> Enum.map(&calc_threshold/1)
    |> calc_next_thresholds()
    |> MapSet.new()
  end

  @spec calc_anime_ids(rule_t) :: rule_t
  defp calc_anime_ids(rule) do
    anime_ids =
      Neko.Anime.all()
      |> filter_animes(rule)
      |> Enum.map(& &1.id)
      |> MapSet.new()

    %{rule | anime_ids: anime_ids}
  end

  defp filter_animes(animes, %{filters: nil} = _rule) do
    animes
  end

  defp filter_animes(animes, %{filters: filters} = _rule) do
    animes
    |> filter_by_genre_ids(filters["genre_ids"])
    |> filter_by_anime_ids(filters["anime_ids"])
    |> filter_by_year_lte(filters["year_lte"])
    |> filter_by_episodes_gte(filters["episodes_gte"])
  end

  defp filter_by_genre_ids(animes, nil) do
    animes
  end

  defp filter_by_genre_ids(animes, genre_ids) do
    animes
    |> Enum.reject(&is_nil(&1.genre_ids))
    |> Enum.filter(&lists_overlap?(&1.genre_ids, genre_ids))
  end

  # it's faster than !Enum.empty?(list_1 -- (list_1 -- list_2)),
  # using Kernel.!() is a little bit faster than Kernel.not()
  defp lists_overlap?(list_1, list_2) do
    # credo:disable-for-lines:2
    MapSet.new(list_1)
    |> MapSet.intersection(MapSet.new(list_2))
    |> Enum.empty?()
    |> Kernel.!()
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

  @spec calc_threshold(rule_t) :: rule_t
  defp calc_threshold(%{threshold: threshold} = rule)
       when is_number(threshold) do
    rule
  end

  @spec calc_threshold(rule_t) :: rule_t
  defp calc_threshold(%{threshold: threshold} = rule)
       when is_binary(threshold) do
    %{rule | threshold: parse_threshold(rule)}
  end

  # when threshold is a string value, percent is implied
  defp parse_threshold(rule) do
    percent = rule.threshold |> Float.parse() |> elem(0)
    threshold = MapSet.size(rule.anime_ids) * percent / 100
    threshold |> Float.round(2)
  end

  # access to all rules is required to calculate
  # next threshold so iterate over rules here
  @spec calc_next_thresholds(rules_t) :: rules_t
  defp calc_next_thresholds(rules) do
    rules
    |> Enum.map(fn x ->
      %{x | next_threshold: next_threshold(rules, x)}
    end)
  end

  defp next_threshold(rules, rule) do
    rules
    |> Enum.filter(fn x ->
      x.neko_id == rule.neko_id and x.level == rule.level + 1
    end)
    |> Enum.map(& &1.threshold)
    |> List.first()
  end

  @spec rules() :: rules_t
  defp rules do
    @algo
    |> @rules_reader.read_rules()
    |> MapSet.new()
  end
end
