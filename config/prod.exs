use Mix.Config

# Do not include time - it's provided by systemd journal
config :logger, :console, format: "$metadata[$level] $message\n"
