defmodule Neko.Application do
  use Application

  def start(_type, _args) do
    children = [
      shikimori_pool_child(),
      Neko.Anime.Store,
      Neko.Rule.CountRule.Store,
      rule_worker_pool_child(),
      {Neko.UserRate.Store.Registry, Neko.UserRate.Store.Registry},
      {Neko.Achievement.Store.Registry, Neko.Achievement.Store.Registry},
      user_handler_registry_child(),
      Neko.UserRate.Store.DynamicSupervisor,
      Neko.Achievement.Store.DynamicSupervisor,
      Neko.UserHandler.DynamicSupervisor,
      cowboy_child()
    ]

    opts = [strategy: :rest_for_one, name: Neko.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp shikimori_pool_child do
    config = Application.get_env(:neko, :shikimori)[:pool]

    :hackney_pool.child_spec(
      config[:name],
      timeout: config[:conn_ttl],
      max_connections: config[:max_connections]
    )
  end

  defp rule_worker_pool_child do
    config = Application.get_env(:neko, :rule_worker_pool)

    :poolboy.child_spec(config[:name], [
      {:name, {:local, config[:name]}},
      {:worker_module, config[:module]},
      {:size, config[:size]},
      {:max_overflow, 2}
    ])
  end

  # https://github.com/spscream/ex_banking/blob/master/lib/ex_banking/application.ex
  # https://hexdocs.pm/elixir/master/Registry.html#module-using-in-via
  defp user_handler_registry_child do
    config = Application.get_env(:neko, :user_handler_registry)
    {Registry, keys: :unique, name: config[:name]}
  end

  # https://hexdocs.pm/plug/Plug.Adapters.Cowboy.html#child_spec/1
  defp cowboy_child do
    {Plug.Adapters.Cowboy,
     [
       scheme: :http,
       plug: Neko.Router,
       options: [ip: {127, 0, 0, 1}, port: 4000]
     ]}
  end
end
