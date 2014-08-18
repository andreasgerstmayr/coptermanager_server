defmodule CoptermanagerCore.Serial do
  use GenServer
  alias Porcelain.Process

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %Process{}, opts)
  end

  def init(_state) do
    serial_port = Application.get_env(:coptermanager_core, :serial_port)
    baudrate = Integer.to_string(Application.get_env(:coptermanager_core, :baudrate))
    file_path = Path.join(__DIR__, "../../../external/sendserialcmd.py")
    args = [serial_port, baudrate]
    options = [in: :receive, out: {:send, self()}]

    state = case :os.type() do
      {:unix, _} -> Porcelain.spawn(file_path, args, options)
      {:win32, _} ->
        case Application.get_env(:coptermanager_core, :python_win32_executable) do
          nil -> raise "please specify the path to python.exe"
          _ -> Porcelain.spawn(Application.get_env(:coptermanager_core, :python_win32_executable), [file_path|args], options)
        end
      _ -> raise "Unknown operating system"
    end

    %Porcelain.Process{pid: pid} = state
    receive do
      {^pid, :data, <<"ok", _lf :: binary>>} -> 
        IO.puts "started serial daemon"
        {:ok, state}
    after
      2000 -> {:stop, "error starting python serial daemon"}
    end
  end

  def send_command(server, copterid, command, value) do
    GenServer.call server, {copterid, command, value}
  end

  def handle_call({copterid, command, value}, from, state) when not is_integer(copterid), do: handle_call({0, command, value}, from, state)
  def handle_call({copterid, command, value}, from, state) when not is_integer(value), do: handle_call({copterid, command, 0}, from, state)
  def handle_call({copterid, command, value}, _from, state) do
    Process.send_input(state, "#{copterid} #{command} #{value}\n")

    %Porcelain.Process{pid: pid} = state
    receive do
      {^pid, :data, result} -> {:reply, String.to_integer(String.strip(result)), state}
      _ -> {:reply, 0xFF, state}
    end
  end

  def terminate(_reason, state) do
    Process.send_input(state, "#{0xFF} #{0xFF} #{0xFF}\n")
    :ok
  end

end
