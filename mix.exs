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
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env)
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
      "deploy": [
        "edeliver update production",
        "cmd ssh shiki sudo systemctl restart neko"
      ],
      "deps.clean": ["deps.clean --unused --unlock"],
      "deps.install": ["deps.clean", "deps.get"],
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
      {:edeliver, "~> 1.4.4"},
      {:distillery, "~> 1.4", runtime: false},
      # remove when new version (> v0.1.0) is released
      # (Mox.stub/3 is in master now)
      {:mox, git: "https://github.com/plataformatec/mox", only: :test},
      # other yaml parsers don't support merging maps
      # (except for Yomel but it fails to start in production)
      {:yamler, git: "https://github.com/tap349/yamler", branch: "mapping_as_map"}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
