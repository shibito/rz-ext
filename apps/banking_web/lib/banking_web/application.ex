defmodule BankingWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: BankingWeb.PubSub},
      BankingWeb.Telemetry,
      # Start a worker by calling: BankingWeb.Worker.start_link(arg)
      # {BankingWeb.Worker, arg},
      # Start to serve requests, typically the last entry
      BankingWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BankingWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BankingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
