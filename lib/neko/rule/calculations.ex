defmodule Neko.Rule.Calculations do
  @typep rule_t :: Neko.Rule.t()
  @typep rules_t :: MapSet.t(rule_t)

  @spec calc_anime_ids(rules_t) :: rules_t
  def calc_anime_ids(rules) do
    rules
    |> Enum.map(&%{&1 | anime_ids: rule_anime_ids(&1)})
    |> MapSet.new()
  end

  @spec calc_thresholds(rules_t, (rule_t -> number)) :: rules_t
  def calc_thresholds(rules, threshold) do
    rules
    |> Enum.map(&%{&1 | threshold: threshold.(&1)})
    |> calc_next_thresholds()
    |> MapSet.new()
  end

  @spec calc_durations(rules_t) :: rules_t
  def calc_durations(rules) do
    rules
    |> Enum.map(&%{&1 | duration: anime_duration(&1.anime_ids)})
    |> MapSet.new()
  end

  @spec anime_duration(MapSet.t(pos_integer)) :: pos_integer
  def anime_duration(anime_ids) do
    Neko.Anime.all()
    |> Enum.filter(&Enum.member?(anime_ids, &1.id))
    |> Enum.map(&(&1.episodes * &1.duration))
    |> Enum.sum()
  end

  @spec rule_anime_ids(rule_t) :: MapSet.t(pos_integer)
  defp rule_anime_ids(rule) do
    Neko.Anime.all()
    |> Neko.Rule.Filters.filter_animes(rule)
    |> Enum.map(& &1.id)
    |> MapSet.new()
  end

  # access to all rules is required to calculate
  # next threshold so iterate over rules here
  @spec calc_next_thresholds(rules_t) :: rules_t
  defp calc_next_thresholds(rules) do
    rules
    |> Enum.map(&%{&1 | next_threshold: next_threshold(rules, &1)})
  end

  @spec next_threshold(rules_t, rule_t) :: number
  defp next_threshold(rules, rule) do
    rules
    |> Enum.filter(fn x ->
      x.neko_id == rule.neko_id and x.level == rule.level + 1
    end)
    |> Enum.map(& &1.threshold)
    |> List.first()
  end
end
