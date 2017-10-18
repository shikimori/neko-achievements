defmodule Neko.Application do
  @moduledoc false
  use Application

  @registry_name :user_handler_registry

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # https://hexdocs.pm/plug/Plug.Adapters.Cowboy.html#child_spec/1
    cowboy_child = {Plug.Adapters.Cowboy, [
      scheme: :http,
      plug: Neko.Router,
      options: [ip: {127, 0, 0, 1}, port: 4000]
    ]}

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
      worker(Neko.UserRate.Store.Registry, []),
      worker(Neko.Achievement.Store.Registry, []),
      supervisor(Neko.UserRate.Store.Supervisor, []),
      supervisor(Neko.Achievement.Store.Supervisor, []),
      supervisor(Registry, [:unique, @registry_name]),
      supervisor(Neko.UserHandler.Supervisor, []),
      # default value of :restart option is :temporary
      # (it's required when using Task.Supervisor.async_nolink/2)
      supervisor(Task.Supervisor, [[name: Neko.TaskSupervisor]]),
      cowboy_child
    ]

    opts = [strategy: :rest_for_one, name: Neko.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
