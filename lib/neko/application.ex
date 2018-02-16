defmodule Neko.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Neko.Worker.start_link(arg1, arg2, arg3)
      # worker(Neko.Worker, [arg1, arg2, arg3]),
      #
      # use supervisor with simple_one_for_one strategy when it's
      # necessary to dynamically start and stop supervised children
      # (as is the case with user rate or achievement stores since
      # they are created on the fly for each new user unlike anime
      # or simple rule stores)
      worker(Neko.Anime.Store, []),
      worker(Neko.Rules.SimpleRule.Store, []),
      simple_rule_worker_pool_child(),
      worker(Neko.UserRate.Store.Registry, []),
      worker(Neko.Achievement.Store.Registry, []),
      user_handler_registry_child(),
      supervisor(Neko.UserRate.Store.Supervisor, []),
      supervisor(Neko.Achievement.Store.Supervisor, []),
      supervisor(Neko.UserHandler.Supervisor, []),
      cowboy_child()
    ]

    opts = [strategy: :rest_for_one, name: Neko.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp simple_rule_worker_pool_child do
    config = Neko.Rules.SimpleRule.worker_pool_config()

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
    # same as: supervisor(Registry, [:unique, config[:name]])
    {Registry,
     [
       keys: :unique,
       name: config[:name]
     ]}
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
