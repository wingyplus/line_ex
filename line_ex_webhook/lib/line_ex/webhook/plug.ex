defmodule LineEx.Webhook.Plug do
  @moduledoc """
  A Plug module to accept LINE webhook events from LINE Messaging API webhook.
  """

  import Plug.Conn

  @behaviour Plug

  @impl true
  def init(opts) do
    %{
      channel_secret: Keyword.fetch!(opts, :channel_secret),
      webhook: Keyword.fetch!(opts, :webhook)
    }
  end

  @impl true
  def call(%{method: "POST"} = conn, opts) do
    case LineEx.Webhook.Signature.verify(conn, opts.channel_secret) do
      {:ok, body, conn} ->
        LineEx.Webhook.handle_event(opts.webhook, Jason.decode!(body))

        conn
        |> send_resp(200, "OK")

      :invalid_signature ->
        conn
        |> send_resp(400, "Invalid signature")
        |> halt()
    end
  end

  @impl true
  def call(conn, _opts) do
    conn
    |> send_resp(405, "Method not allowed")
    |> halt()
  end
end
