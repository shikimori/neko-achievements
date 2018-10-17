# https://medium.com/elixirlabs/registry-in-elixir-1-4-0-d6750fb5aeb
# https://github.com/amokan/registry_sample
defmodule Neko.UserHandler do
  # there is no need to restart UserHandler process:
  #
  # - if it terminates (because of crash or receive timeout),
  #   associated key (user_id) is removed from the registry
  # - new UserHandler process for that user_id is started
  #   when new request for that user_id arrives
  use GenServer, restart: :temporary
  require Logger

  @registry_config Application.get_env(:neko, :user_handler_registry)
  @registry_name @registry_config[:name]
  @call_timeout @registry_config[:call_timeout]
  @recv_timeout @registry_config[:recv_timeout]

  # ------------------------------------------------------------------
  # Client API
  # ------------------------------------------------------------------

  # registry with a name `@registry_name` is started as part
  # of a supervision tree (it's a supervisor itself).
  #
  # if started GenServer process has a :via tuple name, it's
  # automatically registered in the registry under that name
  # (using :via tuple is one of the ways to register process
  # in the registry).
  #
  # so one of the benefits of using Registry is that you don't
  # have to define it yourself.
  def start_link(user_id) do
    GenServer.start_link(__MODULE__, user_id, name: via_tuple(user_id))
  end

  def process(%{user_id: user_id} = request) do
    GenServer.call(via_tuple(user_id), {:process, request}, @call_timeout)
  end

  defp via_tuple(user_id) do
    {:via, Registry, {@registry_name, user_id}}
  end

  # ------------------------------------------------------------------
  # Server API
  # ------------------------------------------------------------------

  def init(user_id) do
    Logger.info("process for user_id #{user_id} started...")

    # use GenServer only as a backpressure mechanism to throttle
    # processing of shikimori requests per user_id -> GenServer
    # process doesn't have to persist any state
    {:ok, user_id}
  end

  def handle_call({:process, request}, _from, state) do
    diff = Neko.Request.process(request)
    {:reply, diff, state, @recv_timeout}
  end

  def handle_info(:timeout, state) do
    Logger.info("process for user_id #{state} terminated (timeout)")

    # stop both achievement and user rate stores
    # for this user_id to reduce memory consumption
    # (they are both monitored by their registries)
    Neko.UserRate.stop(state)
    Neko.Achievement.stop(state)

    {:stop, :normal, state}
  end
end
