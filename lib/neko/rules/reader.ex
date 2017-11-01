defmodule Neko.Rules.Reader do
  defmodule Behaviour do
    @callback read_rules(String.t()) :: list(%Neko.Rules.SimpleRule{})
  end

  @behaviour Behaviour
  @rules_dir Application.get_env(:neko, :rules)[:dir]

  def read_rules(algo) do
    read_from_file(algo)
    |> Enum.map(&Neko.Rules.SimpleRule.new/1)
  end

  defp read_from_file(algo) do
    Application.app_dir(:neko, @rules_dir)
    |> Path.join("*.yml")
    |> Path.wildcard()
    |> Enum.map(&read_from_file_async/1)
    |> Enum.flat_map(&Task.await/1)
    |> Enum.filter(&(&1["algo"] == algo))
  end

  defp read_from_file_async(file) do
    Task.async(fn ->
      {:ok, [yml]} = :yaml.load_file(file)
      yml
    end)
  end
end
