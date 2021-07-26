defmodule EchoPhoenixWeb.Router do
  use EchoPhoenixWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", EchoPhoenixWeb do
    pipe_through :api
  end

  forward "/webhook", LineEx.Webhook.Plug,
    channel_secret: System.get_env("LINE_CHANNEL_SECRET"),
    webhook: EchoPhoenix.Webhook
end
