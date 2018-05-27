defmodule Neko.Rule.Calculations do
  @typep rule_t :: Neko.Rule.t()
  @typep rules_t :: MapSet.t(rule_t)

  @spec calc_anime_ids(rules_t) :: rules_t
  def calc_anime_ids(rules) do
    rules
    |> Enum.map(&%{&1 | anime_ids: rule_anime_ids(&1)})
    |> MapSet.new()
  end

  @spec calc_thresholds(rules_t) :: rules_t
  def calc_thresholds(rules) do
    rules
    |> Enum.map(&%{&1 | threshold: Neko.Rule.CountRule.threshold(&1)})
    |> calc_next_thresholds()
    |> MapSet.new()
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

  defp next_threshold(rules, rule) do
    rules
    |> Enum.filter(fn x ->
      x.neko_id == rule.neko_id and x.level == rule.level + 1
    end)
    |> Enum.map(& &1.threshold)
    |> List.first()
  end
end
