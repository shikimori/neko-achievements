defmodule Neko.Achievement.Calculator do
  @active_rules Application.get_env(:neko, :active_rules)

  def call(user_id) do
    @active_rules
    |> Enum.flat_map(fn(x) -> apply(x, :achievements, [user_id]) end)
  end
end
