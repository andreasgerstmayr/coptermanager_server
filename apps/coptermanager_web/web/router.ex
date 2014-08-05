defmodule CoptermanagerWeb.Router do
  use Phoenix.Router

  plug Plug.Static, at: "/static", from: :coptermanager_web
  get "/", CoptermanagerWeb.PageController, :index, as: :page

  get "/api/copter", CoptermanagerWeb.Api.CopterController, :list
  get "/api/copter/bind", CoptermanagerWeb.Api.CopterController, :bind
  get "/api/copter/:copterid/:command", CoptermanagerWeb.Api.CopterController, :command
end
