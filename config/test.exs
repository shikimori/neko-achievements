use Mix.Config

config :neko, :shikimori_client, Neko.Shikimori.MockClient
# shikimori_url key is not used in mock client
config :neko, :rules, reader: Neko.Rules.MockReader

config :appsignal, :config, active: false
