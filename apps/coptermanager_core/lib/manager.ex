defmodule CoptermanagerCore.Manager do
  use GenServer

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
    cmdcode = 0x01
    # TODO: send bind cmd (0x01), wait response
    copterid = 5

    state = %State{copters: [copterid|state.copters]}
    {:reply, copterid, state}
  end

  def handle_call({:command, copterid, command, value}, _from, state) do
    cmdcode = case command do
      "throttle" -> 0x02
      "rudder" -> 0x03
      "aileron" -> 0x04
      "elevator" -> 0x05
      "led" -> 0x06
      "flip" -> 0x07
      "video" -> 0x08
      "land" -> 0x09
    end

    # TODO: send cmd, wait response
    resultcode = 0

    {:reply, resultcode, state}
  end
end
