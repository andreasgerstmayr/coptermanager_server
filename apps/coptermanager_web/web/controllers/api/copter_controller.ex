defmodule CoptermanagerWeb.Api.CopterController do
  use Phoenix.Controller
  use Jazz
  use Timex
  alias CoptermanagerWeb.Config

  def list(conn, _params) do
    copters = GenServer.call(Config.get(:manager_node), {:list})
    copters = Enum.map copters, fn(c) ->
      %{"name" => c.name, "fly_time" => round(Time.elapsed(c.bind_time, :secs))}
    end
    json conn, JSON.encode!(copters)
  end

  def bind(conn, %{"name" => name, "type" => type}) do
    json = case GenServer.call(Config.get(:manager_node), {:bind, name, type}) do
      {:ok, uuid} ->
        %{"result" => "success", "uuid" => uuid}
      {:error, errormessage} ->
        %{"result" => "error", "error" => errormessage}
    end
    json conn, JSON.encode!(json)
  end
  def bind(conn, _params) do
    json = %{"result" => "error", "error" => "please specify the copter name and the copter type"}
    json conn, JSON.encode!(json)
  end

  def command(conn, %{"uuid" => uuid, "command" => command, "value" => value}) do
    json = case GenServer.call(Config.get(:manager_node), {:command, uuid, command, value}) do
      :ok ->
        %{"result" => "success"}
      {:error, errormessage} ->
        %{"result" => "error", "error" => errormessage}
    end
    json conn, JSON.encode!(json)
  end
  def command(conn, %{"uuid" => uuid, "command" => command}) do
    command(conn, %{"uuid" => uuid, "command" => command, "value" => nil})
  end
end
