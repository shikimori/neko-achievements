use Mix.Config

# shikimori url key is not used in mock client
config :neko, :shikimori, client: Neko.Shikimori.ClientMock
config :neko, :rules, reader: Neko.Rule.ReaderMock

config :appsignal, :config, active: false
