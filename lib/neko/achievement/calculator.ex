# https://github.com/thestonefox/elixir_poolboy_example
defmodule Neko.Achievement.Calculator do
  @moduledoc false

  def call(user_id) do
    pool_config = Application.get_env(:neko, :rule_worker_pool)

    Application.get_env(:neko, :rules)[:module_list]
    |> Enum.flat_map(fn rule_module ->
      :poolboy.transaction(
        pool_config[:name],
        fn pid ->
          pool_config[:module]
          |> apply(:achievements, [pid, rule_module, user_id])
        end,
        pool_config[:wait_timeout]
      )
    end)
    |> MapSet.new()
  end
end
