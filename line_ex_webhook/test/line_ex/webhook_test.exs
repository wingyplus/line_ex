defmodule LineEx.WebhookTest do
  use ExUnit.Case, async: true
  alias Plug.Conn

  defmodule UpdateStateHandlerTest do
    use LineEx.Webhook

    def start_link(args, opts \\ []) do
      LineEx.Webhook.start_link(__MODULE__, args, opts)
    end

    @impl true
    def init(args) do
      {:ok, Enum.into(args, %{})}
    end

    @impl true
    def handle_event(_event, state) when is_map(state) do
      {:reply, "<reply_token>", [%{type: "text", text: "Hello"}], state}
    end
  end

  defmodule SimpleHandlerTest do
    use LineEx.Webhook

    def start_link(args, opts \\ []) do
      LineEx.Webhook.start_link(__MODULE__, args, opts)
    end

    @impl true
    def init(_opts) do
      {:ok, %{}}
    end

    @impl true
    def handle_event(%{"events" => [event]}, state) when is_map(state) do
      {:reply, event["replyToken"], [%{type: "text", text: "Hello"}], state}
    end
  end

  setup do
    bypass = Bypass.open()
    %{bypass: bypass}
  end

  test "handle_event/2 update new state after send to handler", %{bypass: bypass} do
    Bypass.expect_once(bypass, "POST", "/v2/bot/message/reply", fn conn ->
      Conn.resp(conn, 200, "{}")
    end)

    args = [
      channel_access_token: "<channel_access_token>",
      line_api_url: line_api_url(bypass),
      akey: :value
    ]

    webhook = start_supervised!({UpdateStateHandlerTest, args})

    LineEx.Webhook.handle_event(webhook, build(:message_event))

    assert %{state: %{akey: :value}} = :sys.get_state(webhook)
  end

  test "handle_event/2 send reply message to line api", %{bypass: bypass} do
    self = self()

    Bypass.expect_once(bypass, "POST", "/v2/bot/message/reply", fn conn ->
      send(self, {:authorization, Conn.get_req_header(conn, "authorization")})
      {:ok, req_body, conn} = Conn.read_body(conn)
      send(self, {:request_body, Jason.decode!(req_body)})
      Conn.resp(conn, 200, "{}")
    end)

    args = [
      channel_access_token: "<channel_access_token>",
      line_api_url: line_api_url(bypass),
      akey: :value
    ]

    webhook = start_supervised!({SimpleHandlerTest, args})

    LineEx.Webhook.handle_event(webhook, build(:message_event))
    # Wait handle cast to be done.
    _ = :sys.get_state(webhook)

    assert_receive {:authorization, ["Bearer <channel_access_token>"]}

    assert_receive {:request_body,
                    %{
                      "replyToken" => "nHuyWiB7yP5Zw52FIkcQobQuGDXCTA",
                      "messages" => [%{"type" => "text", "text" => "Hello"}]
                    }}
  end

  defp line_api_url(bypass), do: "http://localhost:#{bypass.port}"

  defp build(:message_event) do
    %{
      "destination" => "xxxxxxxxxx",
      "events" => [
        %{
          "replyToken" => "nHuyWiB7yP5Zw52FIkcQobQuGDXCTA",
          "type" => "message",
          "mode" => "active",
          "timestamp" => 1_462_629_479_859,
          "source" => %{
            "type" => "user",
            "userId" => "U4af4980629..."
          },
          "message" => %{
            "id" => "325708",
            "type" => "text",
            "text" => "Hello, world!"
          }
        }
      ]
    }
  end
end
