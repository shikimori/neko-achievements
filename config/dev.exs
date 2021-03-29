use Mix.Config

config :neko, :cowboy, listen_address: {127, 0, 0, 1}
config :neko, :cowboy, listen_port: 4004

if System.get_env("SHIKIMORI_LOCAL") == "true" do
  config :neko, :shikimori, url: "http://shikimori.local/api/"
else
  config :neko, :shikimori, url: "https://shikimori.one/api/"
end

# config :appsignal, :config, active: false
