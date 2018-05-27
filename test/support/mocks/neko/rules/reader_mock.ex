defmodule Neko.Rules.ReaderMock do
  @behaviour Neko.Rules.Reader.Behaviour

  @impl true
  def read_rules(_algo), do: []
end
