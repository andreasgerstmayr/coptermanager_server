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
      {:ok, copterid} ->
        %{"result" => "success", "copterid" => copterid}
      {:error, errormessage} ->
        %{"result" => "error", "error" => errormessage}
    end
    json conn, JSON.encode!(json)
  end

  def bind(conn, _params) do
    json = %{"result" => "error", "error" => "please specify the copter name and the copter type"}
    json conn, JSON.encode!(json)
  end

  def command(conn, %{"copterid" => copterid, "command" => command, "value" => value}) when is_integer(copterid) do
    json = case GenServer.call(Config.get(:manager_node), {:command, copterid, command, value}) do
      :ok ->
        %{"result" => "success"}
      :bound ->
        %{"result" => "success", "state" => "bound"}
      :unbound ->
        %{"result" => "success", "state" => "unbound"}
      {:error, errormessage} ->
        %{"result" => "error", "error" => errormessage}
    end
    json conn, JSON.encode!(json)
  end

  def command(conn, %{"copterid" => copterid, "command" => command, "value" => value}) when not is_integer(copterid) do
    copterid_parsed = Integer.parse(copterid)
    cond do
      copterid_parsed != :error and elem(copterid_parsed, 0) > 0 ->
        command(conn, %{"copterid" => elem(copterid_parsed, 0), "command" => command, "value" => value})

      true ->
        json = %{"result" => "error", "error" => "copterid must be an integer greater than 0"}
        json conn, JSON.encode!(json)
    end
  end

  def command(conn, %{"copterid" => copterid, "command" => command}) do
    command(conn, %{"copterid" => copterid, "command" => command, "value" => nil})
  end
end
