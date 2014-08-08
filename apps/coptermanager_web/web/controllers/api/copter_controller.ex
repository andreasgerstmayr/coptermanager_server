defmodule CoptermanagerWeb.Api.CopterController do
  use Phoenix.Controller
  use Jazz

  def list(conn, _params) do
    copters = GenServer.call(:manager, {:list})
    json conn, JSON.encode!(copters)
  end

  def bind(conn, %{"type" => type}) do
    json = case GenServer.call(:manager, {:bind, type}) do
      {:ok, copterid} ->
        %{"result" => "success", "copterid" => copterid}
      {:error, errormessage} ->
        %{"result" => "error", "error" => errormessage}
    end
    json conn, JSON.encode!(json)
  end
  def bind(conn, %{}) do
    json = %{"result" => "error", "error" => "please specify the copter type in the 'type' query parameter"}
    json conn, JSON.encode!(json)
  end

  def command(conn, %{"copterid" => copterid, "command" => command, "value" => value}) do
    json = case Integer.parse(copterid) do
      :error ->
        %{"result" => "error", "error" => "invalid copterid, must be a number"}
      {copterid, _} when copterid < 1 ->
        %{"result" => "error", "error" => "invalid copterid, must be a positive number (greater than 0)"}
      {copterid, _} ->
        case GenServer.call(:manager, {:command, copterid, command, value}) do
          :ok ->
            %{"result" => "success"}
          {:error, errormessage} ->
            %{"result" => "error", "error" => errormessage}
        end
    end
    json conn, JSON.encode!(json)
  end
  
  def command(conn, %{"copterid" => copterid, "command" => command}) do
    command(conn, %{"copterid" => copterid, "command" => command, "value" => nil})
  end
end
