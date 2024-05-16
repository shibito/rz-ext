defmodule BankingCore.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    topologies = Application.get_env(:libcluster, :topologies) || []

    children = [
      # Starts a worker by calling: BankingCore.Worker.start_link(arg)
      # {BankingCore.Worker, arg}
      {Cluster.Supervisor, [topologies, [name: BankingCore.ClusterSupervisor]]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BankingCore.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
