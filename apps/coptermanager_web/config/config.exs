# This file is responsible for configuring your application
use Mix.Config

# Note this file is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project.

config :phoenix, CoptermanagerWeb.Router,
  port: System.get_env("PORT"),
  ssl: false,
  code_reload: false,
  static_assets: true,
  cookies: true,
  session_key: "_coptermanager_web_key",
  session_secret: "EPW44*)_P$O1LQMIX0$#E^@4L5R%4KWO5(#!S7(ZI712HOXP0#(V^7=GVFPMV8^QU@7D8K@)I!YJ"

config :phoenix, :logger,
  level: :error


# Import environment specific config. Note, this must remain at the bottom of
# this file to properly merge your previous config entries.
import_config "#{Mix.env}.exs"