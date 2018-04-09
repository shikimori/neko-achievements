defmodule Neko.Rules.ReaderMock do
  @moduledoc false
  @behaviour Neko.Rules.Reader.Behaviour

  @impl true
  def read_rules(_algo), do: []
end
