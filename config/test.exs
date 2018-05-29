use Mix.Config

config :neko, :cowboy, listen_address: [ip: {127, 0, 0, 1}, port: 4000]

# shikimori url key is not used in mock client
config :neko, :shikimori, client: Neko.Shikimori.ClientMock
config :neko, :rules, reader: Neko.Rule.ReaderMock

config :appsignal, :config, active: false
