defmodule EchoPlug do
  @moduledoc false

  use Plug.Router

  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:json],
    body_reader: {LineEx.Webhook.BodyReader, :read_body, []},
    json_decoder: Jason

  plug :match
  plug :dispatch

  forward "/webhook",
    to: LineEx.Webhook.Plug,
    init_opts: [channel_secret: System.get_env("LINE_CHANNEL_SECRET"), webhook: EchoPlug.Webhook]

  match _ do
    conn
    |> send_resp(404, "Not Found")
  end
end
