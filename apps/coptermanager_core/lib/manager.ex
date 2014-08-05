defmodule CoptermanagerCore.Manager do
  use GenServer
  alias CoptermanagerCore.Protocol

  defmodule State do
    defstruct copters: []
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, %State{}, opts)
  end

  def handle_call({:list}, _from, state) do
    {:reply, state.copters, state}
  end

  def handle_call({:bind, type}, _from, state) do
    cmdcode = Protocol.commands.copter_bind
    type = Protocol.types[type]
    # TODO: send bind cmd (0x01), wait response
    copterid = 5

    state = %State{copters: [copterid|state.copters]}
    {:reply, copterid, state}
  end

  def handle_call({:command, copterid, command, value}, _from, state) do
    commandcodes = Protocol.commands()
    cmdcode = case command do
      "throttle" -> commandcodes.copter_throttle
      "rudder" -> commandcodes.copter_rudder
      "aileron" -> commandcodes.copter_aileron
      "elevator" -> commandcodes.copter_elevator
      "led" -> commandcodes.copter_led
      "flip" -> commandcodes.copter_flip
      "video" -> commandcodes.copter_video
      "land" -> commandcodes.copter_land
    end

    case command do
      "led" ->
        value = case value do
          "on" -> 0x01
          "off" -> 0x00
        end
      _ ->
    end

    # TODO: send cmd, wait response
    resultcode = 0

    {:reply, resultcode, state}
  end
end
