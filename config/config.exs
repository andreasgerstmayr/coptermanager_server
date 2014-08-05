# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for third-
# party users, it should be done in your mix.exs file.

# Sample configuration:
#
#     config :logger,
#       level: :info,
#       format: "$time $metadata[$level] $message\n"

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"

# Finally, note that configuration defined in children projects
# inside apps/ are not automatically available to the umbrella parent.
# They can, however, be easily imported:
#
#     import_config "../apps/foo/config/config.exs"
#     import_config "../apps/bar/config/config.exs"
