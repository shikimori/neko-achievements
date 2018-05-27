defmodule Neko.Rules.SimpleRule do
  @moduledoc false
  @behaviour Neko.Rules.Rule

  alias Neko.Rules.SimpleRule.Store

  @impl true
  defdelegate reload, to: Store
  @impl true
  defdelegate all, to: Store

  @impl true
  def set(rules) do
    Store.set(rules)
    Neko.Rules.Rule.reload_all_rules()
  end

  @impl true
  def value(rule, user_anime_ids) do
    user_anime_ids
    |> MapSet.intersection(rule.anime_ids)
    |> MapSet.size()
  end
end
