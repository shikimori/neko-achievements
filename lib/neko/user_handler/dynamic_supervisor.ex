# it's used just like Neko.UserRate.Store.DynamicSupervisor
# except that store registry is provided by Elixir's Registry
defmodule Neko.UserHandler.DynamicSupervisor do
  @moduledoc false

  use DynamicSupervisor
  require Logger

  @name __MODULE__
  @registry_name Application.get_env(:neko, :user_handler_registry)[:name]

  # ------------------------------------------------------------------
  # Client API
  # ------------------------------------------------------------------

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: @name)
  end

  def create_missing_handler(user_id) do
    case Registry.lookup(@registry_name, user_id) do
      [] ->
        handler = user_id |> create_handler()

        # getting child count inside init/1 of user handler
        # itself blocks execution
        #
        # %{active: 2, specs: 1, supervisors: 0, workers: 2}
        total = DynamicSupervisor.count_children(@name).active
        Logger.info("total count of user handlers - #{total}")

        handler

      _ ->
        {:ok, user_id}
    end
  end

  # well, generally speaking we don't care about the result of
  # starting child here - it can be useful for debugging only
  defp create_handler(user_id) do
    child_spec = {Neko.UserHandler, user_id}

    case DynamicSupervisor.start_child(@name, child_spec) do
      {:ok, _pid} ->
        {:ok, user_id}

      {:error, {:already_started, _pid}} ->
        {:error, :already_started}

      other ->
        Logger.error("unknown error: #{inspect(other)}")
        {:error, other}
    end
  end

  # ------------------------------------------------------------------
  # Server API
  # ------------------------------------------------------------------

  # https://stackoverflow.com/a/6882456/3632318
  #
  # requests in the queue are not saved anywhere -
  # they are lost when UserHandler process crashes
  #
  # if extra_arguments are specified they are prepended to
  # the list of arguments for Neko.UserHandler.start_link
  def init(_initial_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
