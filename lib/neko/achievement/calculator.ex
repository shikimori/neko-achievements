# https://github.com/thestonefox/elixir_poolboy_example
defmodule Neko.Achievement.Calculator do
  def call(user_id) do
    config = Application.get_env(:neko, :rule_worker_pool)

    Application.get_env(:neko, :rules)[:module_list]
    |> Enum.flat_map(fn rule_module ->
      :poolboy.transaction(
        config[:name],
        fn pid ->
          config[:module]
          |> apply(:achievements, [pid, rule_module, user_id])
        end,
        config[:wait_timeout]
      )
    end)
    |> MapSet.new()
  end
end
