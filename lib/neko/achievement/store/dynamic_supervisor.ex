defmodule Neko.Achievement.Store.DynamicSupervisor do
  @moduledoc false

  use DynamicSupervisor

  @name __MODULE__

  # ------------------------------------------------------------------
  # Client API
  # ------------------------------------------------------------------

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: @name)
  end

  def start_store do
    child_spec = Neko.Achievement.Store
    DynamicSupervisor.start_child(@name, child_spec)
  end

  # ------------------------------------------------------------------
  # Server API
  # ------------------------------------------------------------------

  def init(_initial_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
