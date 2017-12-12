defmodule Neko.Rules.SimpleRule.Worker do
  use GenServer
  require Logger

  #------------------------------------------------------------------
  # Client API
  #------------------------------------------------------------------

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state)
  end

  def achievements(pid, user_id) do
    GenServer.call(pid, {:achievements, user_id})
  end

  #------------------------------------------------------------------
  # Server API
  #------------------------------------------------------------------

  def init(_) do
    Logger.info("simple rule worker started...")
    {:ok, Neko.Rules.SimpleRule.all()}
  end

  def handle_call({:achievements, user_id}, _from, rules) do
    achievements = Neko.Rules.SimpleRule.achievements(rules, user_id)
    {:reply, achievements, rules}
  end
end
