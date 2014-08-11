defmodule CoptermanagerWeb.CopterController do
  use Phoenix.Controller
  use Timex
  alias CoptermanagerWeb.Config

  def index(conn, _params) do
    copters = GenServer.call(Config.get(:manager_node), {:list})
    render conn, "index", copters: copters
  end

  def copterlist(conn, _params) do
    copters = GenServer.call(Config.get(:manager_node), {:list})
    render conn, "copterlist", within: nil, copters: copters
  end

  def show(conn, %{"uuid" => uuid}) do
    copter = GenServer.call(Config.get(:manager_node), {:get, uuid})
    copters = GenServer.call(Config.get(:manager_node), {:list})

    case copter do
      nil -> text conn, :not_found, "Copter with id #{uuid} not found."
      _ ->
        copter_type = GenServer.call(Config.get(:manager_node), {:get_copter_type, copter.copter_type})
        flying_time = round(Time.elapsed(copter.bind_time, :secs))
        render conn, "show", copter: copter, copters: copters, copter_type: copter_type, flying_time: flying_time
    end
  end

  def launch(conn, _params) do
    copters = GenServer.call(Config.get(:manager_node), {:list})
    render conn, "launch", copters: copters, api_endpoint: "http://localhost:4000/api"
  end
end
