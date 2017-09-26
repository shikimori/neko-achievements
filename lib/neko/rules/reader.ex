defmodule Neko.Rules.Reader do
  @rules_dir Application.get_env(:neko, :rules)[:dir]

  def read_from_files(algo) do
    Application.app_dir(:neko, @rules_dir)
    |> Path.join("*.yml")
    |> Path.wildcard()
    |> Enum.map(&read_from_file_async(&1))
    |> Enum.flat_map(&Task.await/1)
    |> Enum.filter(&(&1["algo"] == algo))
  end

  defp read_from_file_async(file) do
    Task.async(fn -> YamlElixir.read_from_file(file) end)
  end
end
