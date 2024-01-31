defmodule LiveCue.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LiveCueWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:live_cue, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: LiveCue.PubSub},
      # Start a worker by calling: LiveCue.Worker.start_link(arg)
      # {LiveCue.Worker, arg},
      # Start to serve requests, typically the last entry
      LiveCueWeb.Endpoint,
      LiveCue.DB,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveCue.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LiveCueWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
