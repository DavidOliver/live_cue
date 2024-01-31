import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :live_cue, LiveCueWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "rkSom8zcDXG6uhSjNsmUvXAO0wOXNMHKg04hYmFgzCAPLhah2+p9C0Wa12t7t0uS",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
