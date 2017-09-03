defmodule Neko.Rules.Reader do
  @rules_yml Application.get_env(:neko, :rules)[:yml]

  def read_from_file(type) do
    Application.app_dir(:neko, @rules_yml)
    |> YamlElixir.read_from_file()
    |> Enum.filter(&(&1["type"] == type))
  end
end
