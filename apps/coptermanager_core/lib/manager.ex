defmodule CoptermanagerCore.Manager do
  use GenServer
  use Timex
  alias CoptermanagerCore.Protocol
  alias CoptermanagerCore.Config

  defmodule Copter do
    defstruct [:copterid, :pin, :name, :copter_type, :init_time, :bound]
  end

  defmodule State do
    defstruct copters: []
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %State{}, opts)
  end

  def init(state) do
    {:ok, _} = :timer.send_interval(Config.get(:copters_sync_interval) * 1000, :copters_sync)
    {:ok, state}
  end

  defp create_copter(copterid, name, copter_type) do
    %Copter{copterid: copterid, pin: UUID.uuid4(), name: name, copter_type: copter_type, init_time: Time.now, bound: false}
  end

  defp get_copter(copterid, state) do
    Enum.find(state.copters, fn(c) -> c.copterid == copterid end)
  end

  defp get_error_message(errorcode) do
    case Protocol.statuscodes do
      %{:protocol_invalid_copter_type => ^errorcode} -> "invalid copter type"
      %{:protocol_all_slots_full => ^errorcode} -> "all slots are full"
      %{:protocol_invalid_slot => ^errorcode} -> "invalid slot"
      %{:protocol_value_out_of_range => ^errorcode} -> "value out of range"
      %{:protocol_emergency_mode_on => ^errorcode} -> "emergency mode on"
      %{:protocol_unknown_command => ^errorcode} -> "unknown command"
      _ -> "unknown error"
    end
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
            {:reply, {:error, get_error_message(copterid)}, state}

          true ->
            copter = create_copter(copterid, name, type)
            state = %State{state | copters: [copter|state.copters]}
            {:reply, {:ok, copter.copterid}, state}
        end
    end
  end

  def handle_call({:command, copterid, command, value}, _from, state) do
    copter = get_copter(copterid, state)

    cmdcode = case command do
      "throttle" -> Protocol.commands.copter_throttle
      "rudder" -> Protocol.commands.copter_rudder
      "aileron" -> Protocol.commands.copter_aileron
      "elevator" -> Protocol.commands.copter_elevator
      "led" -> Protocol.commands.copter_led
      "flip" -> Protocol.commands.copter_flip
      "video" -> Protocol.commands.copter_video
      "emergency" -> Protocol.commands.copter_emergency
      "disconnect" -> Protocol.commands.copter_disconnect
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
            {:reply, {:error, get_error_message(result)}, state}

          true ->
            case command do
              "disconnect" ->
                copters = List.delete(state.copters, copter)
                state = %State{state | copters: copters}
                {:reply, :ok, state}
              _ ->
                {:reply, :ok, state}
            end
        end
    end
  end

  def copter_update_bind_state(copter) do
    bound_state = GenServer.call(:serial, {copter.copterid, Protocol.commands.copter_getstate, 0})
    bound = case Protocol.statuscodes do
      %{:protocol_unbound => ^bound_state} -> false
      %{:protocol_bound => ^bound_state} -> true
      _ -> copter.bound
    end
    %Copter{copter | bound: bound}
  end

  def handle_info(:copters_sync, state) do
    bitmask = GenServer.call(:serial, {0, Protocol.commands.copter_listcopters, 0})

    copters = state.copters
    |> Enum.filter(fn(c) ->
      use Bitwise
      (bitmask &&& (1 <<< (c.copterid-1))) != 0
    end)
    |> Enum.map(&copter_update_bind_state/1)
    
    state = %State{state | copters: copters}
    {:noreply, state}
  end
end
