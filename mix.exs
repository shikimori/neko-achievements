defmodule Neko.Mixfile do
  use Mix.Project

  def project do
    [
      app: :neko,
      version: "0.2.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # dependencies are added to `applications` by default -
    # specify only extra applications from Erlang/Elixir
    #
    # appsignal must be started before application
    # (extra_applications are started before applications)
    [
      # extra_applications: [:logger, :appsignal],
      extra_applications: [:logger],
      mod: {Neko.Application, []}
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
      {:plug_cowboy, "~> 1.0"},
      {:exconstructor, "~> 1.0"},
      {:poison, "~> 4.0"},
      {:httpoison, "~> 1.0"},
      {:edeliver, "~> 1.4"},
      {:distillery, "~> 2.0"},
      {:mox, "~> 0.4", only: :test},
      # other yaml parsers don't support merging maps
      # (except for Yomel but it fails to start in production)
      #
      # in my fork I just cherry-picked commit with Makefile and
      # new rebar.config from master into mapping_as_map branch
      # (without Makefile compiled libyaml.so library is not placed into
      # _build/<env>/lib/yamler/priv/ and consequently not found both in
      # production and on CircleCI)
      {
        :yamler,
        git: "https://github.com/tap349/yamler", branch: "mapping_as_map"
      },
      # {:appsignal, "~> 1.0"},
      {:poolboy, "~> 1.5"},
      {:credo, "~> 0.9", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      "deps.install": ["deps.clean --unused --unlock", "deps.get"],
      test: "test --no-start",
      deploy: &deploy/1
    ]
  end

  defp deploy(_) do
    Mix.Task.run(:edeliver, ["update", "production"])
    Mix.shell().info("[neko updated]")

    Mix.Task.run(:cmd, ["ssh devops@88.198.7.116 sudo systemctl restart neko"])
    Mix.shell().info("[neko restarted]")

    # Mix.Task.rerun(:edeliver, ["ping", "production"])
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
