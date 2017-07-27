defmodule Neko.Rules.BasicRule do
  defstruct ~w(
    neko_id
    level
    threshold
  )a

  use ExConstructor, atoms: true, strings: true

  def achievements(user_id) do
  end

  defp rules do
    Neko.Rules.BasicRule.Store.all()
  end

  defp user_rates(user_id) do
    {:ok, store_pid} = Neko.UserRate.Store.Registry.lookup(user_id)
    Neko.UserRate.Store.all(store_pid)
  end

  defp progress value, threshold do
    # TODO calculated based on current threshold and previous rule threshold
  end
end
