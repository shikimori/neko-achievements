defmodule Neko.Rules.MockReader do
  @behaviour Neko.Rules.Reader.Behaviour

  def read_rules(_algo), do: []
end
