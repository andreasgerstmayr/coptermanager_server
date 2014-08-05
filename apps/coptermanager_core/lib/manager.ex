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
    cmdcode = Protocol.commands.COPTER_BIND
    # TODO: send bind cmd (0x01), wait response
    copterid = 5

    state = %State{copters: [copterid|state.copters]}
    {:reply, copterid, state}
  end

  def handle_call({:command, copterid, command, value}, _from, state) do
    commandcodes = Protocol.commands()
    cmdcode = case command do
      "throttle" -> commandcodes.throttle
      "rudder" -> commandcodes.rudder
      "aileron" -> commandcodes.aileron
      "elevator" -> commandcodes.elevator
      "led" -> commandcodes.led
      "flip" -> commandcodes.flip
      "video" -> commandcodes.video
      "land" -> commandcodes.land
    end

    # TODO: send cmd, wait response
    resultcode = 0

    {:reply, resultcode, state}
  end
end
