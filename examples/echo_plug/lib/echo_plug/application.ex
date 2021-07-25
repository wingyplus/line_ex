defmodule EchoPlug.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    channel_access_token = System.get_env("LINE_CHANNEL_ACCESS_TOKEN")

    children = [
      {EchoPlug.Webhook, channel_access_token: channel_access_token, name: EchoPlug.Webhook},
      {Plug.Cowboy, scheme: :http, plug: EchoPlug, options: [port: 5000]}
    ]

    opts = [strategy: :one_for_one, name: EchoPlug.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
