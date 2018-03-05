# https://github.com/thestonefox/elixir_poolboy_example
defmodule Neko.Achievement.Calculator do
  @moduledoc false

  @rules_list Application.get_env(:neko, :rules)[:list]

  def call(user_id) do
    @rules_list
    |> Enum.flat_map(fn rule ->
      config = apply(rule, :worker_pool_config, [])

      :poolboy.transaction(
        config[:name],
        fn pid -> apply(config[:module], :achievements, [pid, user_id]) end,
        config[:wait_timeout]
      )
    end)
  end
end
