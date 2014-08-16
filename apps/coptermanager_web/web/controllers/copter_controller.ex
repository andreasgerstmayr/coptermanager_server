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

  def show(conn, %{"copterid" => copterid}) when is_integer(copterid) do
    copter = GenServer.call(Config.get(:manager_node), {:get, copterid})
    copters = GenServer.call(Config.get(:manager_node), {:list})

    case copter do
      nil ->
        render conn, "show", copters: copters

      _ ->
        copter_type = GenServer.call(Config.get(:manager_node), {:get_copter_type, copter.copter_type})
        init_time = round(Time.elapsed(copter.init_time, :secs))
        render conn, "show", copter: copter, copters: copters, copter_type: copter_type, init_time: init_time, api_endpoint: "http://localhost:4000/api"
    end
  end

  def show(conn, %{"copterid" => copterid}) when not is_integer(copterid) do
    copterid_parsed = Integer.parse(copterid)
    cond do
      copterid_parsed != :error and elem(copterid_parsed, 0) > 0 ->
        show(conn, %{"copterid" => elem(copterid_parsed, 0)})

      true ->
        text conn, :not_found, "coperid must be an integer greater than 0."
    end
  end

  def launch(conn, _params) do
    copters = GenServer.call(Config.get(:manager_node), {:list})
    render conn, "launch", copters: copters, api_endpoint: "http://localhost:4000/api"
  end
end
