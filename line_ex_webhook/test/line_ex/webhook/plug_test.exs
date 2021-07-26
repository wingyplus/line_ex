defmodule LineEx.Webhook.PlugTest do
  use ExUnit.Case, async: true
  use Plug.Test
  import LineEx.Factory

  defmodule SimpleWebhook do
    use LineEx.Webhook

    def start_link(args, opts \\ []) do
      LineEx.Webhook.start_link(__MODULE__, args, opts)
    end

    def init(_args), do: {:ok, %{hit: 0}}

    def handle_event(_event, state) do
      {:noreply, %{state | hit: 1}}
    end
  end

  setup do
    webhook =
      start_supervised!({SimpleWebhook, channel_access_token: build(:valid_channel_access_token)})

    %{webhook: webhook}
  end

  setup %{webhook: webhook} do
    %{
      opts:
        LineEx.Webhook.Plug.init(
          channel_secret: build(:valid_channel_secret),
          webhook: webhook
        )
    }
  end

  test "400: no x-line-signature header", %{opts: opts} do
    conn =
      build_request("/webhook", build(:message_event))
      |> LineEx.Webhook.Plug.call(opts)

    assert {400, _, "Invalid signature"} = sent_resp(conn)
  end

  test "400: invalid channel secret", %{opts: opts} do
    conn =
      build_request("/webhook", build(:message_event), true,
        channel_secret: build(:invalid_channel_secret)
      )
      |> LineEx.Webhook.Plug.call(opts)

    assert {400, _, "Invalid signature"} = sent_resp(conn)
  end

  test "200: return OK", %{webhook: webhook, opts: opts} do
    conn =
      build_request("/webhook", build(:message_event), true,
        channel_secret: build(:valid_channel_secret)
      )
      |> LineEx.Webhook.Plug.call(opts)

    assert {200, _, "OK"} = sent_resp(conn)
    assert %{state: %{hit: 1}} = :sys.get_state(webhook)
  end

  defp sign_request(channel_secret, request_body) do
    :crypto.mac(:hmac, :sha256, channel_secret, request_body)
    |> Base.encode64()
  end

  defp build_request(path, payload, sign_request? \\ false, opts \\ []) do
    request_body = Jason.encode!(payload)

    conn("post", path, request_body)
    |> put_private(:raw_body, request_body)
    |> Map.replace(:body_params, payload)
    |> maybe_sign_request(sign_request?, request_body, opts)
  end

  defp maybe_sign_request(conn, false, _, _), do: conn

  defp maybe_sign_request(conn, true, request_body, opts) do
    conn
    |> put_req_header("x-line-signature", sign_request(opts[:channel_secret], request_body))
  end
end
