defmodule Neko.Rules.SimpleRule.Worker do
  @moduledoc false

  use GenServer
  require Logger

  # ------------------------------------------------------------------
  # Client API
  # ------------------------------------------------------------------

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def achievements(pid, user_id) do
    GenServer.call(pid, {:achievements, user_id})
  end

  # reload rules from store
  def reload(pid) do
    GenServer.call(pid, {:reload})
  end

  # ------------------------------------------------------------------
  # Server API
  # ------------------------------------------------------------------

  def init(_) do
    Logger.info("simple rule worker started...")
    {:ok, rules()}
  end

  def handle_call({:achievements, user_id}, _from, rules) do
    achievements = Neko.Rules.SimpleRule.achievements(rules, user_id)
    {:reply, achievements, rules}
  end

  def handle_call({:reload}, _from, _rules) do
    {:reply, :ok, rules()}
  end

  defp rules do
    Neko.Rules.SimpleRule.all()
  end
end
