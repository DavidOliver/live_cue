# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :live_cue,
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :live_cue, LiveCueWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: LiveCueWeb.ErrorHTML, json: LiveCueWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: LiveCue.PubSub,
  live_view: [signing_salt: "gyX99Zf+"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  default: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :libcluster,
  topologies: [
    epmd: [
      strategy: Elixir.Cluster.Strategy.Epmd,
      config: [
        # timeout: 30_000,
        hosts: [
          :"livecue@172.24.127.250", # blue
          :"livecue@172.24.45.12",   # sanguinalis
          :"livecue@172.24.89.103",  # Seraph
          :"livecue@172.24.31.30",   # Ian-Nuc
          :"livecue@172.24.11.64",   # ZeroOne
        ]
      ]
    ]
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
