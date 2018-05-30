defmodule Neko.Rule.DurationRule do
  @behaviour Neko.Rule

  alias Neko.Rule.DurationRule.Store

  @typep rule_t :: Neko.Rule.t()
  @typep rules_t :: MapSet.t(rule_t)
  @typep anime_t :: Neko.Anime.t()
  @typep animes_by_id_t :: %{optional(pos_integer) => anime_t}

  @impl true
  defdelegate reload, to: Store
  @impl true
  defdelegate all, to: Store

  @impl true
  @spec threshold(rules_t) :: any
  def set(rules) do
    Store.set(rules)
    Neko.Rule.reload_all_rules()
  end

  @impl true
  @spec threshold(rule_t) :: number
  def threshold(%{threshold: threshold}) when is_number(threshold) do
    threshold
  end

  # when threshold is a string value ("100%"), percent is implied
  @impl true
  @spec threshold(rule_t) :: float
  def threshold(%{threshold: threshold} = rule) when is_binary(threshold) do
    percent = rule.threshold |> Float.parse() |> elem(0)
    threshold = rule.duration * percent / 100
    threshold |> Float.round(2)
  end

  @impl true
  @spec value(rule_t, animes_by_id_t) :: pos_integer
  def value(rule, user_animes_by_id) do
    user_animes_by_id
    |> Map.take(rule.anime_ids)
    |> Map.values()
    |> Enum.map(& &1.total_duration)
    |> Enum.sum()
  end
end
