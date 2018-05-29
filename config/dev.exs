use Mix.Config

config :neko, :cowboy, listen_address: [ip: {127, 0, 0, 1}, port: 4000]

if System.get_env("SHIKIMORI_LOCAL") do
  config :neko, :shikimori, url: "https://shikimori.local/api/"
else
  config :neko, :shikimori, url: "https://shikimori.org/api/"
end

config :appsignal, :config, active: false
