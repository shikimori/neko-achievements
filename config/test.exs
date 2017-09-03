use Mix.Config

config :neko, :shikimori_client, Neko.Shikimori.Client.Mock

config :neko, :rules,
  yml: "priv/rules_test.yml",
  active_rules: [Neko.Rules.BasicRule]
