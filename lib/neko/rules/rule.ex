defmodule Neko.Rules.Rule do
  @moduledoc false

  defstruct ~w(
    neko_id
    level
    threshold
    filters
    next_threshold
    anime_ids
    duration
  )a

  use ExConstructor, atoms: true, strings: true

  @type t :: %__MODULE__{}

  @callback reload() :: any
  @callback all() :: MapSet.t(t)
  @callback set([t]) :: any
  @callback value(t, [pos_integer]) :: pos_integer

  # reload rules in all poolboy workers when new rules are set
  def reload_all_rules do
    config = Application.get_env(:neko, :rule_worker_pool)
    all_workers = GenServer.call(config[:name], :get_avail_workers)

    all_workers
    |> Enum.each(fn pid -> apply(config[:module], :reload, [pid]) end)
  end

  # rules are taken from worker state to avoid excessive copying
  def achievements(rules, user_id, rule_module) do
    # precalculate user_anime_ids before passing them to rule_module.value/2:
    # processing is ~10ms longer when creating MapSet in rule_module.value/2
    user_anime_ids =
      user_id
      |> Neko.UserRate.all()
      |> Enum.map(& &1.target_id)
      |> MapSet.new()

    # final list of achievements for all rules is converted to MapSet
    # in Neko.Achievement.Calculator
    rules
    |> Enum.map(&{&1, apply(rule_module, :value, [&1, user_anime_ids])})
    |> Enum.filter(&rule_applies?/1)
    |> Enum.map(&build_achievement(&1, user_id))
  end

  defp rule_applies?({rule, value}) do
    value >= rule.threshold
  end

  defp build_achievement({rule, value}, user_id) do
    %Neko.Achievement{
      user_id: user_id,
      neko_id: rule.neko_id,
      level: rule.level,
      progress: progress(rule, value)
    }
  end

  defp progress(%{next_threshold: nil}, _value) do
    100
  end

  defp progress(%{threshold: threshold}, value)
       when value == threshold do
    0
  end

  defp progress(%{next_threshold: next_threshold}, value)
       when value >= next_threshold do
    100
  end

  defp progress(rule, value) do
    %{threshold: threshold, next_threshold: next_threshold} = rule
    progress = (value - threshold) / (next_threshold - threshold) * 100
    progress |> Float.floor()
  end
end
