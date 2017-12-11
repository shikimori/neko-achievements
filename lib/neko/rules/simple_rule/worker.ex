defmodule Neko.Rules.SimpleRule.Worker do
  use GenServer

  #------------------------------------------------------------------
  # Client API
  #------------------------------------------------------------------

  def start_link do
    GenServer.start_link(__MODULE__, [])
  end

  def achievements(pid, user_id) do
    GenServer.call(pid, {:achievements, user_id})
  end

  #------------------------------------------------------------------
  # Server API
  #------------------------------------------------------------------

  def init(_) do
    {:ok, {Neko.Rules.SimpleRule.all()}}
  end

  def handle_call({:achievements, user_id}, _from, rules) do
    achievements = Neko.Rules.SimpleRule.achievements(rules, user_id)
    {:reply, achievements, rules}
  end
end
