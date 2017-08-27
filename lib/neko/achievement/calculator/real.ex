defmodule Neko.Achievement.Calculator.Real do
  @behaviour Neko.Achievement.Calculator
  @active_rules Application.get_env(:neko, :active_rules)

  def call(user_id) do
    @active_rules
    |> Enum.flat_map(fn(x) -> apply(x, :achievements, [user_id]) end)
    |> MapSet.new()
  end
end
