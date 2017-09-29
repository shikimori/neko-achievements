defmodule Neko.Rules.SimpleRule do
  @behaviour Neko.Rules.Rule

  defstruct ~w(
    neko_id
    level
    threshold
    filters
    next_threshold
    anime_ids
  )a

  use ExConstructor, atoms: true, strings: true

  def all do
    Neko.Rules.SimpleRule.Store.all()
  end

  def achievements(user_rates, user_id) do
    all()
    |> Enum.map(fn(x) -> {x, count(x, user_rates)} end)
    |> Enum.filter(&rule_applies?(&1))
    |> Enum.map(&build_achievement(&1, user_id))
  end

  defp count(rule, user_rates) do
    user_rates
    |> Enum.filter(&(MapSet.member?(rule.anime_ids, &1.target_id)))
    |> length()
  end

  defp rule_applies?({rule, count}) do
    count >= rule.threshold
  end

  defp build_achievement({rule, count}, user_id) do
    %Neko.Achievement{
      user_id: user_id,
      neko_id: rule.neko_id,
      level: rule.level,
      progress: progress(rule, count)
    }
  end

  defp progress(%{next_threshold: nil}, _count) do
    100
  end
  defp progress(%{threshold: threshold}, count)
  when count == threshold do
    0
  end
  defp progress(%{next_threshold: next_threshold}, count)
  when count >= next_threshold do
    100
  end
  defp progress(rule, count) do
    %{threshold: threshold, next_threshold: next_threshold} = rule
    ((count - threshold) / (next_threshold - threshold)) * 100 |> round()
  end
end
