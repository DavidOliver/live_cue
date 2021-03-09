import Config

secret_key_base =
  System.get_env("SECRET_KEY_BASE") ||
    raise """
    Environment variable SECRET_KEY_BASE is missing.
    You can generate one by calling: mix phx.gen.secret
    """

config :live_cue, LiveCueWeb.Endpoint,
  http: [
    port: String.to_integer(System.get_env("PORT") || "4000"),
    transport_options: [socket_opts: [:inet6]]
  ],
  secret_key_base: secret_key_base

collection_directory =
  System.get_env("COLLECTION_DIRECTORY") ||
    raise "Environment variable COLLECTION_DIRECTORY is missing."

config :live_cue, :collection_directory, collection_directory

db_directory =
  System.get_env("DB_DIRECTORY") ||
    raise "Environment variable DB_DIRECTORY is missing."

config :live_cue, :db_directory, db_directory
