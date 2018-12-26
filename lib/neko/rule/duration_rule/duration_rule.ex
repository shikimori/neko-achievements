defmodule Neko.Rule.DurationRule do
  @behaviour Neko.Rule

  alias Neko.Rule.DurationRule.Store

  @typep rule_t :: Neko.Rule.t()
  @typep rules_t :: MapSet.t(rule_t)
  @typep by_anime_id_t :: Neko.Rule.by_anime_id_t()

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
    Float.round(threshold, 2)
  end

  @impl true
  @spec value(rule_t, MapSet.t(pos_integer), by_anime_id_t()) :: pos_integer
  def value(rule, _user_anime_ids, by_anime_id) do
    by_anime_id
    |> Map.take(rule.anime_ids)
    |> Enum.map(fn {_, %{user_rate: user_rate, anime: anime}} ->
      if user_rate.status == "watching" || user_rate.status == "on_hold" do
        anime.duration * user_rate.episodes
      else
        anime.total_duration
      end
    end)
    |> Enum.sum()
  end
end
