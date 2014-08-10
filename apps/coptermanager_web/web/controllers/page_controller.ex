defmodule CoptermanagerWeb.PageController do
  use Phoenix.Controller

  def index(conn, _params) do
    redirect conn, "/copter"
  end
end
