defmodule CoptermanagerCore.Manager do
  use GenServer
  use Timex
  alias CoptermanagerCore.Protocol

  defmodule Copter do
    defstruct [:copterid, :pin, :name, :copter_type, :bind_time]
  end

  defmodule State do
    defstruct copters: []
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %State{}, opts)
  end

  def init(state) do
    {:ok, _} = :timer.send_interval(Protocol.inactivity_timer * 1000, :inactivity_check)
    {:ok, state}
  end

  defp create_copter(copterid, name, copter_type) do
    %Copter{copterid: copterid, pin: UUID.uuid4(), name: name, copter_type: copter_type, bind_time: Time.now}
  end

  defp get_copter(copterid, state) do
    Enum.find(state.copters, fn(c) -> c.copterid == copterid end)
  end

  def handle_call({:list}, _from, state) do
    {:reply, state.copters, state}
  end

  def handle_call({:get, copterid}, _from, state) do
    copter = get_copter(copterid, state)
    {:reply, copter, state}
  end

  def handle_call({:get_copter_type, copter_type}, _from, state) do
    {type_name, _type_value} = Enum.find(Protocol.types, fn({_name, value}) -> value == copter_type end)
    {:reply, type_name, state}
  end

  def handle_call({:bind, name, type}, _from, state) do
    cmdcode = Protocol.commands.copter_bind
    type = Protocol.types[type]

    case type do
      nil ->
        {:reply, {:error, "unknown type"}, state}

      _ ->
        copterid = GenServer.call(:serial, {nil, cmdcode, type})
        
        cond do
          copterid >= 0xF0 ->
            {:reply, {:error, "unknown type or all copter slots are in use"}, state}

          true ->
            copter = create_copter(copterid, name, type)
            state = %State{copters: [copter|state.copters]}
            {:reply, {:ok, copter.copterid}, state}
        end
    end
  end

  def handle_call({:command, copterid, command, value}, _from, state) do
    copter = get_copter(copterid, state)

    commandcodes = Protocol.commands
    cmdcode = case command do
      "throttle" -> commandcodes.copter_throttle
      "rudder" -> commandcodes.copter_rudder
      "aileron" -> commandcodes.copter_aileron
      "elevator" -> commandcodes.copter_elevator
      "led" -> commandcodes.copter_led
      "flip" -> commandcodes.copter_flip
      "video" -> commandcodes.copter_video
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
        result = GenServer.call(:serial, {copter.copterid, cmdcode, value})
        cond do
          result >= 0xF0 ->
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

  def copter_active?(copter) do
    case Time.elapsed(copter.bind_time, :secs) < Protocol.max_inactivity_time do
      true -> true
      false ->
        GenServer.call(:serial, {copter.copterid, Protocol.commands.copter_disconnect, nil})
        false
    end
  end

  def handle_info(:inactivity_check, state) do
    copters = Enum.filter(state.copters, &copter_active?/1)
    state = %State{copters: copters}
    {:noreply, state}
  end
end
