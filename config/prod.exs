use Mix.Config

config :neko, :application, listen_adress: [ip: {192, 168, 0, 2}, port: 4000]
# Do not include time - it's provided by systemd journal
config :logger, :console, format: "$metadata[$level] $message\n"
