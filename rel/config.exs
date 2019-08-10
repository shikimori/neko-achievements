# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
#
# credo:disable-for-lines:2 Credo.Check.Refactor.PipeChainStart
Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Distillery.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: Mix.env()

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html

# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"WE`H9ZX]9asjWk*U&Iy]W8RAJS4Z<XueUrK_{iL$QT~3Np@{AMp!f~SlUu1GN~vD"
end

# cookie is set in vm.args
environment :prod do
  set vm_args: "rel/vm.args"
  set include_erts: true
  set include_src: false
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :neko do
  set version: current_version(:neko)
  set applications: [
    :runtime_tools
  ]
end
