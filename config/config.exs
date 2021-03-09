# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Configures the endpoint
config :live_cue, LiveCueWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "AuPOtc7puhcwCgpkiteZJzOqpmPXBGjYtttMQ9jQo44oPjkTcFYKW2JpMILsCLtW",
  render_errors: [view: LiveCueWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: LiveCue.PubSub,
  live_view: [signing_salt: "nLArVp40"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
