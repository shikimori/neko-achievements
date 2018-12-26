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
  @type by_anime_id_t :: %{
          optional(pos_integer) => %{
            required(:user_rate) => Neko.UserRate.t(),
            required(:anime) => Neko.Anime.t()
          }
        }

  @callback reload() :: any
  @callback all() :: MapSet.t(t)
  @callback set([t]) :: any
  @callback threshold(t) :: pos_integer
  # this function is called for each rule so it must be very cheap
  @callback value(t, MapSet.t(pos_integer), by_anime_id_t) :: pos_integer

  # reload rules in all poolboy workers when new rules are set
  def reload_all_rules do
    config = Application.get_env(:neko, :rule_worker_pool)
    all_workers = GenServer.call(config[:name], :get_avail_workers)

    all_workers
    |> Enum.each(fn pid -> apply(config[:module], :reload, [pid]) end)
  end

  # rules and animes are taken from worker state to avoid excessive copying
  def achievements(rule_module, rules, animes_by_id, user_id) do
    by_anime_id =
      user_id
      |> Neko.UserRate.all()
      |> Enum.reduce(%{}, fn {_id, x}, acc ->
        Map.put(
          acc,
          x.target_id,
          %{user_rate: x, anime: animes_by_id[x.target_id]}
        )
      end)

    user_anime_ids =
      by_anime_id
      |> Enum.reject(fn {_, %{user_rate: user_rate}} ->
        user_rate.status == "watching"
      end)
      |> Enum.into(%{})
      |> Map.keys()
      |> MapSet.new()

    # final list of achievements for all rules is converted to MapSet in
    # Neko.Achievement.Calculator
    rules
    |> Enum.map(fn rule ->
      args = [rule, user_anime_ids, by_anime_id]
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
