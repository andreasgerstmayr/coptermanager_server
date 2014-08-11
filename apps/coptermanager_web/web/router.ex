defmodule CoptermanagerWeb.Router do
  use Phoenix.Router

  plug Plug.Static, at: "/static", from: :coptermanager_web
  get "/", CoptermanagerWeb.PageController, :index

  get "/copter", CoptermanagerWeb.CopterController, :index
  get "/copter/_copterlist", CoptermanagerWeb.CopterController, :copterlist
  get "/copter/launch", CoptermanagerWeb.CopterController, :launch
  get "/copter/:uuid", CoptermanagerWeb.CopterController, :show

  get "/api", CoptermanagerWeb.Api.ApiController, :index
  get "/api/copter", CoptermanagerWeb.Api.CopterController, :list
  post "/api/copter", CoptermanagerWeb.Api.CopterController, :bind
  post "/api/copter/:uuid/:command", CoptermanagerWeb.Api.CopterController, :command
end
