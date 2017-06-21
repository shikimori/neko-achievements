defmodule Neko.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  alias Neko.UserRate.Store.Registry, as: UserRateRegistry
  alias Neko.Achievement.Store.Registry, as: AchievementRegistry
  alias Neko.UserRate.Store.Supervisor, as: UserRateSupervisor
  alias Neko.Achievement.Store.Supervisor, as: AchievementSupervisor

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Neko.Worker.start_link(arg1, arg2, arg3)
      # worker(Neko.Worker, [arg1, arg2, arg3]),
      worker(UserRateRegistry, [UserRateRegistry]),
      worker(AchievementRegistry, [AchievementRegistry]),
      supervisor(UserRateSupervisor, []),
      supervisor(AchievementSupervisor, []),
      Plug.Adapters.Cowboy.child_spec(:http, Neko.Router, [], [port: 4001])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    #
    # one_for_one: only crashed child will be restarted
    opts = [strategy: :rest_for_one, name: Neko.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
