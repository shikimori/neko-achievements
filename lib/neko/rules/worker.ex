defmodule Neko.Rules.Worker do
  @moduledoc false

  use GenServer
  require Logger

  # ------------------------------------------------------------------
  # Client API
  # ------------------------------------------------------------------

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg)
  end

  def achievements(pid, rule_module, user_id) do
    GenServer.call(pid, {:achievements, rule_module, user_id})
  end

  # reload rules from store
  def reload(pid) do
    GenServer.call(pid, {:reload})
  end

  # ------------------------------------------------------------------
  # Server API
  # ------------------------------------------------------------------

  def init(_) do
    Logger.info("rule worker started...")
    {:ok, rules()}
  end

  def handle_call({:achievements, rule_module, user_id}, _from, rules) do
    achievements =
      rule_module
      |> apply(:achievements, [rules[rule_module], user_id])

    {:reply, achievements, rules}
  end

  def handle_call({:reload}, _from, _rules) do
    {:reply, :ok, rules()}
  end

  defp rules do
    Application.get_env(:neko, :rules)[:module_list]
    |> Enum.reduce(%{}, fn rule_module, acc ->
      Map.put(acc, rule_module, apply(rule_module, :all, []))
    end)
  end
end
