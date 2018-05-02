use Mix.Config

if System.get_env("SHIKIMORI_LOCAL") do
  config :neko, :shikimori, url: "https://shikimori.local/api/"
else
  config :neko, :shikimori, url: "https://shikimori.org/api/"
end

config :appsignal, :config, active: false
