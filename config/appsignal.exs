use Mix.Config

# appsignal will create appsignal/ subdirectory
# inside specified working directory
config :appsignal, :config,
  name: "Neko",
  push_api_key: "a4eef92b-c361-477e-bb65-c34e6d911e54",
  env: Mix.env(),
  working_dir_path: "/home/apps/neko/",
  active: true
