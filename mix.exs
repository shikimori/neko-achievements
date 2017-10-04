defmodule Neko.Mixfile do
  use Mix.Project

  def project do
    [
      app: :neko,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # dependencies are added to `applications` by default -
    # specify only extra applications from Erlang/Elixir
    [
      extra_applications: [:logger],
      mod: {Neko.Application, []}
    ]
  end

  defp aliases do
    [
      "deps.clean": ["deps.clean --unused --unlock"],
      "test": "test --no-start"
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:cowboy, "~> 1.1"},
      {:exconstructor, "~> 1.1.0"},
      {:plug, "~> 1.4"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 0.12"},
      {:yaml_elixir, "~> 1.1"},
      {:edeliver, "~> 1.4.4"},
      {:distillery, "~> 1.4", runtime: false}
    ]
  end
end
