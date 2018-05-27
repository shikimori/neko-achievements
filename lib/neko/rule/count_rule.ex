defmodule Neko.Rule.CountRule do
  @behaviour Neko.Rule

  alias Neko.Rule.CountRule.Store

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
  def value(rule, user_anime_ids) do
    user_anime_ids
    |> MapSet.intersection(rule.anime_ids)
    |> MapSet.size()
  end
end
