defmodule Neko.Achievement.Calculator do
  @rules_list Application.get_env(:neko, :rules)[:list]

  # achievements are stored as MapSet in Neko.Achievement.Store
  def call(user_rates, user_id) do
    @rules_list
    |> Enum.flat_map(&apply(&1, :achievements, [user_rates, user_id]))
    |> MapSet.new()
  end
end
