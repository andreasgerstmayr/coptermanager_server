defmodule CoptermanagerCore.Manager do
  use GenServer
  use Timex
  alias CoptermanagerCore.Protocol

  defmodule Copter do
    defstruct copterid: 0, uuid: "", name: "", copter_type: Protocol.types["hubsan_x4"], bind_time: Time.now
  end

  defmodule State do
    defstruct copters: []
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %State{}, opts)
  end

  def init(state) do
    {:ok, _} = :timer.send_interval(Protocol.inactivity_timer, :inactivity_check)
    {:ok, state}
  end

  defp exec_python(file, args) do
    case :os.type() do
      {:unix, _} -> Porcelain.exec(file, args)
      {:win32, _} ->
        case Application.get_env(:coptermanager_core, :python_win32_executable) do
          nil -> raise "please specify the path to python.exe"
          _ -> Porcelain.exec(Application.get_env(:coptermanager_core, :python_win32_executable), [file|args])
        end
      _ -> raise "Unknown operating system"
    end
  end

  defp send_serial_command(copterid, command, value) when not is_integer(copterid), do: send_serial_command(0, command, value)
  defp send_serial_command(copterid, command, value) when not is_integer(value), do: send_serial_command(copterid, command, 0)
  defp send_serial_command(copterid, command, value) do
    serial_port = Application.get_env(:coptermanager_core, :serial_port)
    baudrate = Integer.to_string(Application.get_env(:coptermanager_core, :baudrate))
    args = [serial_port, baudrate, Integer.to_string(copterid), Integer.to_string(command), Integer.to_string(value)]
    %Porcelain.Result{out: stdout, err: stderr, status: exitcode} = exec_python(Path.join(__DIR__, "../../../external/sendserialcmd.py"), args)
    {stdout, stderr, exitcode}
  end

  defp get_error_message(stdout, stderr) do
    case stderr do
      nil -> stdout
      _ -> stderr
    end
  end

  defp create_copter(copterid, name, copter_type) do
    %Copter{copterid: copterid, uuid: UUID.uuid4(), name: name, copter_type: copter_type, bind_time: Time.now}
  end

  def handle_call({:list}, _from, state) do
    {:reply, state.copters, state}
  end

  def handle_call({:get, uuid}, _from, state) do
    copter = Enum.find(state.copters, fn(c) -> c.uuid == uuid end)
    {:reply, copter, state}
  end

  def handle_call({:get_copter_type, copter_type}, _from, state) do
    {type_name, type_value} = Enum.find(Protocol.types, fn({name, value}) -> value == copter_type end)
    {:reply, type_name, state}
  end

  def handle_call({:bind, name, type}, _from, state) do
    cmdcode = Protocol.commands.copter_bind
    type = Protocol.types[type]

    case type do
      nil ->
        {:reply, {:error, "unknown type"}, state}

      _ ->
        {stdout, stderr, exitcode} = send_serial_command(nil, cmdcode, type)
        
        cond do
          exitcode != 0 ->
            {:reply, {:error, get_error_message(stderr, stdout)}, state}

          stdout == Integer.to_string(Protocol.statuscodes.protocol_error) ->
            {:reply, {:error, "unknown type or all copter slots are in use"}, state}

          true ->
            {copterid, _} = Integer.parse(stdout)
            copter = create_copter(copterid, name, type)
            state = %State{copters: [copter|state.copters]}
            {:reply, {:ok, copter.uuid}, state}
        end
    end
  end

  def handle_call({:command, uuid, command, value}, _from, state) do
    copter = Enum.find(state.copters, fn(c) -> c.uuid == uuid end)

    commandcodes = Protocol.commands
    cmdcode = case command do
      "throttle" -> commandcodes.copter_throttle
      "rudder" -> commandcodes.copter_rudder
      "aileron" -> commandcodes.copter_aileron
      "elevator" -> commandcodes.copter_elevator
      "led" -> commandcodes.copter_led
      "flip" -> commandcodes.copter_flip
      "video" -> commandcodes.copter_video
      "land" -> commandcodes.copter_land
      "emergency" -> commandcodes.copter_emergency
      "disconnect" -> commandcodes.copter_disconnect
      _ -> nil
    end

    value = cond do
      command in ["led", "flip", "video"] ->
        case value do
          "on" -> 0x01
          "off" -> 0x00
          _ -> nil
        end
      true -> value
    end

    cond do
      copter == nil ->
        {:reply, {:error, "unknown copter"}, state}

      cmdcode == nil ->
        {:reply, {:error, "unknown command"}, state}

      command in ["led", "flip", "video"] and not is_integer(value) ->
        {:reply, {:error, "invalid command value, valid values: 'on', 'off' "}, state}

      command in ["throttle", "rudder", "aileron", "elevator"] and not is_integer(value) ->
        {:reply, {:error, "invalid command value, a integer is required"}, state}

      true ->
        {stdout, stderr, exitcode} = send_serial_command(copter.copterid, cmdcode, value)
        cond do
          exitcode != 0 ->
            {:reply, {:error, get_error_message(stderr, stdout)}, state}

          stdout == Integer.to_string(Protocol.statuscodes.protocol_error) ->
            {:reply, {:error, "command error"}, state}

          true ->
            case command do
              "disconnect" ->
                copters = List.delete(state.copters, copter)
                state = %State{copters: copters}
                {:reply, :ok, state}
              _ ->
                {:reply, :ok, state}
            end
        end
    end
  end

  def handle_info(:inactivity_check, state) do
    copters = Enum.filter(state.copters, fn(c) -> Time.elapsed(c.bind_time, :secs) < Protocol.max_inactivity_time end)
    state = %State{copters: copters}
    {:noreply, state}
  end
end
