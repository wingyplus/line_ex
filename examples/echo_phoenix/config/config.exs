import Config

# Configures the endpoint
config :echo_phoenix, EchoPhoenixWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "/rgZyMVT+MF9ghoE2v6bhRd1zNrMU7QvvJVGwFd9UWDlyXvaH6fG9vbD3tlowYdY",
  render_errors: [view: EchoPhoenixWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: EchoPhoenix.PubSub,
  live_view: [signing_salt: "hUzS2OqN"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :tesla, adapter: {Tesla.Adapter.Finch, name: EchoPhoenix.Finch}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
