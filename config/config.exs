# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :neko, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:neko, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  colors: [
    enabled: true,
    debug: :cyan,
    info: :green,
    warn: :yellow,
    error: :red
  ]

# [120] request timeout (user_handler_registry/call_timeout)
#   -> [110] await timeout of tasks to load user data (shikimori/total_timeout)
#     -> [110] store agent call timeout (shikimori/total_timeout)
#       -> [20] http client connect timeout (shikimori/timeout)
#       -> [90] http client receive timeout (shikimori/recv_timeout)
#   -> [10] poolboy timeout to calculate achievements (simple_rule_worker_pool/timeout)

# https://hexdocs.pm/httpoison/HTTPoison.html#request/5
config :neko, :shikimori,
  client: Neko.Shikimori.HTTPClient,
  url: "https://shikimori.org/api/",
  # connect timeout (8_000 by default)
  conn_timeout: 20_000,
  # receive timeout (5_000 by default)
  recv_timeout: 90_000,
  # timeout + recv_timeout
  total_timeout: 110_000,
  hackney_pool: [
    name: :shikimori_pool,
    # number of connections maintained in pool (50 by default)
    max_connections: 150
  ]

config :neko, :rules,
  dir: "priv/rules",
  list: [Neko.Rules.SimpleRule],
  reader: Neko.Rules.Reader

config :neko, :user_handler_registry,
  name: :user_handler_registry,
  # how long request can wait in the queue to be processed
  call_timeout: 120_000,
  # how long handler process can wait for new message to be received
  recv_timeout: 4 * 3_600_000

config :neko, :simple_rule_worker_pool,
  name: :simple_rule_worker_pool,
  module: Neko.Rules.SimpleRule.Worker,
  size: 15,
  # how long poolboy waits for a worker (5_000 by default)
  wait_timeout: 10_000

import_config "appsignal.exs"

import_config "#{Mix.env()}.exs"
