defmodule LineEx.WebhookPlug do
  @moduledoc """
  A Plug module to accept LINE webhook events from LINE Messaging API webhook.
  """

  import Plug.Conn

  @behaviour Plug

  @impl true
  def init(opts) do
    %{
      channel_secret: Keyword.fetch!(opts, :channel_secret),
      webhook: Keyword.fetch!(opts, :webhook),
      path: Keyword.get(opts, :path, "/")
    }
  end

  @impl true
  def call(%{method: "POST"} = conn, opts) do
    if opts.path == conn.request_path do
      case verify_signature(conn, opts.channel_secret) do
        {:ok, body} ->
          Jason.decode!(body)
          |> (&LineEx.Webhook.handle_event(opts.webhook, &1)).()

          conn
          |> send_resp(200, "OK")

        :invalid_signature ->
          conn
          |> send_resp(400, "Invalid signature")
      end
    else
      conn
    end
  end

  @impl true
  def call(conn, _opts), do: send_resp(conn, 405, "Method not allowed")

  defp verify_signature(conn, channel_secret) when is_binary(channel_secret) do
    signature = get_req_header(conn, "x-line-signature") |> List.first()

    conn
    |> read_body()
    |> case do
      {:ok, body, _conn} ->
        verify_signature(channel_secret, signature, body)

      {:error, _reason} ->
        :invalid_signature
    end
  end

  defp verify_signature(_channel_secret, nil, _body), do: :invalid_signature

  defp verify_signature(channel_secret, signature, body) do
    Base.decode64(signature)
    |> case do
      {:ok, decoded_signature} ->
        if Plug.Crypto.secure_compare(
             decoded_signature,
             :crypto.mac(:hmac, :sha256, channel_secret, body)
           ) do
          {:ok, body}
        else
          :invalid_signature
        end

      :error ->
        :invalid_signature
    end
  end
end
