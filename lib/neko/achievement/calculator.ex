defmodule Neko.Achievement.Calculator do
  # achievements are stored as MapSet in Neko.Achievement.Store
  def call(user_rates, user_id) do
    rules()
    |> Enum.flat_map(&(apply(&1, :achievements, [user_rates, user_id])))
    |> MapSet.new()
  end

  defp rules do
    [Neko.Rules.SimpleRule]
  end
end
