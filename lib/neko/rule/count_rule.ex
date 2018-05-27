defmodule Neko.Rule.CountRule do
  @behaviour Neko.Rule

  alias Neko.Rule.CountRule.Store

  @typep rule_t :: Neko.Rule.t()

  @impl true
  defdelegate reload, to: Store
  @impl true
  defdelegate all, to: Store

  @impl true
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
    threshold |> Float.round(2)
  end

  @impl true
  def value(rule, user_anime_ids) do
    user_anime_ids
    |> MapSet.intersection(rule.anime_ids)
    |> MapSet.size()
  end
end
