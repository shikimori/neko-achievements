defmodule Neko.Achievement.Store.Supervisor do
  @moduledoc """
  Used to group stores.
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      # store won't be restarted if it crashes
      worker(Neko.Achievement.Store, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def start_store do
    Supervisor.start_child(__MODULE__, [])
  end
end
