use Mix.Config

# shikimori url key is not used in mock client
config :neko, :shikimori, client: Neko.Shikimori.MockClient
config :neko, :rules, reader: Neko.Rules.MockReader

config :appsignal, :config, active: false
