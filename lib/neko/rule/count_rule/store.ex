defmodule Neko.Rule.CountRule.Store do
  use Agent

  alias Neko.Rule.{Calculations, CountRule}

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
    Agent.update(@name, fn _ -> calc(rules) end)
  end

  @spec calc(rules_t) :: rules_t
  defp calc(rules) do
    animes = Neko.Anime.all()
    rules
    |> Calculations.calc_anime_ids(animes)
    |> Calculations.calc_thresholds(&CountRule.threshold/1)
  end

  @spec rules() :: rules_t
  defp rules do
    @algo
    |> @rules_reader.read_rules()
    |> MapSet.new()
  end
end
