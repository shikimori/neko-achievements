defmodule Neko.Achievement.Store.Supervisor do
  @moduledoc """
  Used to group stores.
  """

  use Supervisor

  @name Neko.Achievement.Store.Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_store do
    Supervisor.start_child(@name, [])
  end

  def init(:ok) do
    children = [
      worker(Neko.Achievement.Store, [], restart: :temporary)
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
