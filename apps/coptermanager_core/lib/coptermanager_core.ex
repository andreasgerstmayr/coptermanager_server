defmodule CoptermanagerCore do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(CoptermanagerCore.Serial, [[name: :serial]]),
      worker(CoptermanagerCore.Manager, [[name: :manager]])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CoptermanagerCore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
