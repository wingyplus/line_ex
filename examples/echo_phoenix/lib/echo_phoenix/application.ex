defmodule EchoPhoenix.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    channel_access_token = System.get_env("LINE_CHANNEL_ACCESS_TOKEN")

    children = [
      {Finch, name: EchoPhoenix.Finch},
      {EchoPhoenix.Webhook,
       channel_access_token: channel_access_token, name: EchoPhoenix.Webhook},
      # Start the Telemetry supervisor
      EchoPhoenixWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: EchoPhoenix.PubSub},
      # Start the Endpoint (http/https)
      EchoPhoenixWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EchoPhoenix.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    EchoPhoenixWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
