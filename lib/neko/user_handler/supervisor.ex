# it's used just like Neko.UserRate.Store.Supervisor
# except that store registry is provided by Elixir's Registry
defmodule Neko.UserHandler.Supervisor do
  use Supervisor
  require Logger

  @registry_name Application.get_env(:neko, :user_handler_registry)[:name]

  #------------------------------------------------------------------
  # Client API
  #------------------------------------------------------------------

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def create_missing_handler(user_id) do
    case Registry.lookup(@registry_name, user_id) do
      [] -> user_id |> create_handler()
      _ -> {:ok, user_id}
    end
  end

  # well, generally speaking we don't care about the result of
  # starting child here - it can be useful for debugging only
  defp create_handler(user_id) do
    case Supervisor.start_child(__MODULE__, [user_id]) do
      {:ok, _pid} -> {:ok, user_id}
      {:error, {:already_started, _pid}} -> {:error, :already_started}
      other ->
        Logger.error("unknown error: #{inspect(other)}")
        {:error, other}
    end
  end

  #------------------------------------------------------------------
  # Server API
  #------------------------------------------------------------------

  # https://stackoverflow.com/a/6882456/3632318
  #
  # NOTE: requests in the queue are not saved anywhere -
  #       they are lost when UserHandler process crashes
  #
  # there is no need to restart UserHandler process:
  #
  # - if it terminates (because of crash or receive timeout),
  #   associated key (user_id) is removed from the registry
  # - new UserHandler process for that user_id is started
  #   when new request for that user_id arrives
  def init(:ok) do
    children = [worker(Neko.UserHandler, [], restart: :temporary)]
    supervise(children, strategy: :simple_one_for_one)
  end
end
