defmodule Neko.Rule.CountRule.Store do
  use Agent

  @typep rule_t :: Neko.Rule.t()
  @typep rules_t :: MapSet.t(rule_t)

  @name __MODULE__
  @algo "count"
  @rules_reader Application.get_env(:neko, :rules)[:reader]

  @spec start_link(any) :: Agent.on_start()
  def start_link(_) do
    Agent.start_link(fn -> rules() |> calc() end, name: @name)
  end

  @spec reload() :: :ok
  def reload do
    Agent.update(@name, fn _ -> rules() |> calc() end)
  end

  @spec all() :: rules_t
  def all do
    Agent.get(@name, & &1)
  end

  @spec set([rule_t]) :: :ok
  def set(rules) when is_list(rules) do
    rules |> MapSet.new() |> set()
  end

  @spec set(rules_t) :: :ok
  def set(rules) do
    Agent.update(@name, fn _ -> rules |> calc() end)
  end

  @spec calc(rules_t) :: rules_t
  defp calc(rules) do
    rules
    |> Enum.map(&calc_anime_ids/1)
    |> Enum.map(&calc_threshold/1)
    |> calc_next_thresholds()
    |> MapSet.new()
  end

  @spec calc_anime_ids(rule_t) :: rule_t
  defp calc_anime_ids(rule) do
    anime_ids =
      Neko.Anime.all()
      |> Neko.Rule.Filters.filter_animes(rule)
      |> Enum.map(& &1.id)
      |> MapSet.new()

    %{rule | anime_ids: anime_ids}
  end

  @spec calc_threshold(rule_t) :: rule_t
  defp calc_threshold(rule) do
    %{rule | threshold: Neko.Rule.CountRule.threshold(rule)}
  end

  # access to all rules is required to calculate
  # next threshold so iterate over rules here
  @spec calc_next_thresholds(rules_t) :: rules_t
  defp calc_next_thresholds(rules) do
    rules
    |> Enum.map(fn x ->
      %{x | next_threshold: next_threshold(rules, x)}
    end)
  end

  defp next_threshold(rules, rule) do
    rules
    |> Enum.filter(fn x ->
      x.neko_id == rule.neko_id and x.level == rule.level + 1
    end)
    |> Enum.map(& &1.threshold)
    |> List.first()
  end

  @spec rules() :: rules_t
  defp rules do
    @algo
    |> @rules_reader.read_rules()
    |> MapSet.new()
  end
end
