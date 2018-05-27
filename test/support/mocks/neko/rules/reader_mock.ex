defmodule Neko.Rule.ReaderMock do
  @behaviour Neko.Rule.Reader.Behaviour

  @impl true
  def read_rules(_algo), do: []
end
