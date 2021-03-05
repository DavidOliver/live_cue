defmodule LiveCue.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      LiveCueWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: LiveCue.PubSub},
      # Start the Endpoint (http/https)
      LiveCueWeb.Endpoint,
      # Start a worker by calling: LiveCue.Worker.start_link(arg)
      # {LiveCue.Worker, arg}
      LiveCue.DB,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: LiveCue.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    LiveCueWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
