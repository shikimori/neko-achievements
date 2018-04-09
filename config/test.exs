use Mix.Config

# shikimori url key is not used in mock client
config :neko, :shikimori, client: Neko.Shikimori.ClientMock
config :neko, :rules, reader: Neko.Rules.ReaderMock

config :appsignal, :config, active: false
