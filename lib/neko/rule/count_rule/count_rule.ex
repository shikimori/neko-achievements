defmodule Neko.Rule.CountRule do
  @behaviour Neko.Rule

  alias Neko.Rule.CountRule.Store

  @typep rule_t :: Neko.Rule.t()
  @typep rules_t :: MapSet.t(rule_t)
  @typep by_anime_id_t :: Neko.Rule.by_anime_id_t

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
    threshold = MapSet.size(rule.anime_ids) * percent / 100
    Float.round(threshold, 2)
  end

  @impl true
  @spec value(rule_t, MapSet.t(pos_integer), by_anime_id_t()) :: pos_integer
  def value(rule, user_anime_ids, _by_anime_id) do
    # user rates with "watching" status were rejected when
    # calculating user_anime_ids in Neko.Rule.achievements/4
    user_anime_ids
    |> MapSet.intersection(rule.anime_ids)
    |> MapSet.size()

    # this is ~10x slower
    # by_anime_id
    # |> Map.take(rule.anime_ids)
    # |> map_size()
  end
end
