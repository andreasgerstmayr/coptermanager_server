use Mix.Config

config :phoenix, CoptermanagerWeb.Router,
  port: System.get_env("PORT") || 4001,
  ssl: false,
  code_reload: false,
  cookies: true,
  consider_all_requests_local: true,
  session_key: "_coptermanager_web_key",
  session_secret: "EPW44*)_P$O1LQMIX0$#E^@4L5R%4KWO5(#!S7(ZI712HOXP0#(V^7=GVFPMV8^QU@7D8K@)I!YJ"

config :phoenix, :logger,
  level: :debug


