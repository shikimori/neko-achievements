defmodule Neko.Achievement.Calculator do
  @active_rules Application.get_env(:neko, :rules)[:active_rules]

  # return MapSet because achievements are stored
  # as MapSet in Neko.Achievement.Store
  def call(user_rates, user_id) do
    @active_rules
    |> Enum.flat_map(&(apply(&1, :achievements, [user_rates, user_id])))
    |> MapSet.new()
  end
end
