defmodule Neko.Rules.SimpleRule do
  @behaviour Neko.Rules.Rule

  import Float
  alias Neko.Rules.SimpleRule.Store

  defstruct ~w(
    neko_id
    level
    threshold
    filters
    next_threshold
    anime_ids
  )a

  use ExConstructor, atoms: true, strings: true

  defdelegate reload, to: Store
  defdelegate all, to: Store
  defdelegate set(rules), to: Store

  def achievements(user_rates, user_id) do
    # precalculate user_anime_ids before passing them to count/2:
    # processing is ~10ms longer when creating MapSet in count/2
    user_anime_ids =
      user_rates
      |> Enum.map(&(&1.target_id))
      |> MapSet.new()

    all()
    |> Enum.map(fn(x) -> {x, count(x, user_anime_ids)} end)
    |> Enum.filter(&rule_applies?/1)
    |> Enum.map(&build_achievement(&1, user_id))
    |> MapSet.new()
  end

  defp count(rule, user_anime_ids) do
    user_anime_ids
    |> MapSet.intersection(rule.anime_ids)
    |> MapSet.size()
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
    ((count - threshold) / (next_threshold - threshold)) * 100 |> floor()
  end
end
