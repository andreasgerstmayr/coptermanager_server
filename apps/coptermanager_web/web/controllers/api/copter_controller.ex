defmodule CoptermanagerWeb.Api.CopterController do
  use Phoenix.Controller
  use Jazz

  def list(conn, _params) do
    copters = GenServer.call(:manager, {:list})
    json conn, JSON.encode!(copters)
  end

  def bind(conn, %{"type" => type}) do
    copterid = GenServer.call(:manager, {:bind, type})

    result = if copterid > 0 do
      "success"
    else
      "error"
    end

    json = %{"result" => result, "copterid" => copterid}
    json conn, JSON.encode!(json)
  end

  def command(conn, %{"copterid" => copterid, "command" => command, "value" => value}) do
    resultcode = GenServer.call(:manager, {:command, copterid, command, value})

    result = if resultcode >= 0 do
      "success"
    else
      "error"
    end

    json = %{"result" => result, "code" => resultcode}
    json conn, JSON.encode!(json)
  end
  
  def command(conn, %{"copterid" => copterid, "command" => command}) do
    command(conn, %{"copterid" => copterid, "command" => command, "value" => 0})
  end
end
