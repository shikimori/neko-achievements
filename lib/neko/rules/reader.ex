defmodule Neko.Rules.Reader do
  @rules_path Application.get_env(:neko, :rules_path)

  def read_from_file(type) do
    @rules_path
    |> YamlElixir.read_from_file
    |> Enum.filter(&(&1["type"] == type))
  end
end
