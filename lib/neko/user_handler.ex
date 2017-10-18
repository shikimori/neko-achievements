# https://medium.com/elixirlabs/registry-in-elixir-1-4-0-d6750fb5aeb
# https://github.com/amokan/registry_sample
defmodule Neko.UserHandler do
  use GenServer
  require Logger

  @registry_name :user_handler_registry
  # how long request can wait in the queue to be processed
  @timeout 120_000

  #------------------------------------------------------------------
  # Client API
  #------------------------------------------------------------------

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
    GenServer.call(via_tuple(user_id), {:process, request}, @timeout)
  end

  defp via_tuple(user_id) do
    {:via, Registry, {@registry_name, user_id}}
  end

  #------------------------------------------------------------------
  # Server API
  #------------------------------------------------------------------

  def init(user_id) do
    Logger.info("process for user_id #{user_id} started...")

    # use GenServer only as a backpressure mechanism to throttle
    # processing of shikimori requests per user_id - so GenServer
    # process doesn't have to persist any state
    {:ok, user_id}
  end

  def handle_call({:process, request}, _from, state) do
    diff = Neko.Request.process(request)
    {:reply, diff, state}
  end
end
