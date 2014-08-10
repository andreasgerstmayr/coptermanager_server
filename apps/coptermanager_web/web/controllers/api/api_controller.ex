defmodule CoptermanagerWeb.Api.ApiController do
  use Phoenix.Controller

  def index(conn, _params) do
    redirect conn, "https://github.com/andihit/coptermanager_server/blob/master/README.md"
  end
end
