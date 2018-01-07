defmodule Neko.Achievement.Store.Supervisor do
  @moduledoc false

  use Supervisor

  #------------------------------------------------------------------
  # Client API
  #------------------------------------------------------------------

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def start_store do
    Supervisor.start_child(__MODULE__, [])
  end

  #------------------------------------------------------------------
  # Server API
  #------------------------------------------------------------------

  def init(:ok) do
    # store won't be restarted if it crashes
    children = [worker(Neko.Achievement.Store, [], restart: :temporary)]
    supervise(children, strategy: :simple_one_for_one)
  end
end
