defmodule Neko.Rule do
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
  @typep anime_t :: Neko.Anime.t()
  @typep animes_by_id_t :: %{optional(pos_integer) => anime_t}

  @callback reload() :: any
  @callback all() :: MapSet.t(t)
  @callback set([t]) :: any
  @callback threshold(t) :: pos_integer
  # this function is called for each rule so it must be very cheap
  @callback value(t, MapSet.t(pos_integer), animes_by_id_t) :: pos_integer

  # reload rules in all poolboy workers when new rules are set
  def reload_all_rules do
    config = Application.get_env(:neko, :rule_worker_pool)
    all_workers = GenServer.call(config[:name], :get_avail_workers)

    all_workers
    |> Enum.each(fn pid -> apply(config[:module], :reload, [pid]) end)
  end

  # rules and animes are taken from worker state to avoid excessive copying
  def achievements(rule_module, rules, animes_by_id, user_id) do
    user_anime_ids =
      user_id
      |> Neko.UserRate.all()
      |> Enum.map(& &1.target_id)
      |> MapSet.new()

    user_animes_by_id =
      animes_by_id
      |> Map.take(user_anime_ids)

    # final list of achievements for all rules is converted to MapSet in
    # Neko.Achievement.Calculator
    rules
    |> Enum.map(fn rule ->
      # pass both user_anime_ids and user_animes_by_id (rules might
      # calculate their values faster using one data structure than
      # the other)
      args = [rule, user_anime_ids, user_animes_by_id]
      {rule, apply(rule_module, :value, args)}
    end)
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
      progress: Neko.Rule.Progress.progress(rule, value)
    }
  end
end
