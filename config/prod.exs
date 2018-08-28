use Mix.Config

config :neko, :cowboy, listen_address: {192, 168, 0, 2}
config :neko, :cowboy, listen_port: 4000

# Do not include time - it's printed by systemd journal
config :logger, :console, format: "$metadata[$level] $message\n"
