defmodule LineEx.WebhookTest do
  use ExUnit.Case, async: true

  test "handle_event/2 update new state after send to handler" do
    defmodule HandlerTest do
      use LineEx.Webhook

      def handle_event(event, state) when is_map(state) do
        {:reply, "<reply_token>", [%{type: "text", text: "Hello"}], Map.put(state, :akey, :value)}
      end
    end

    webhook = start_supervised!({LineEx.Webhook, handler: {HandlerTest, %{}}})

    LineEx.Webhook.handle_event(webhook, %{
      "destination" => "xxxxxxxxxx",
      "events" => [
        %{
          "replyToken" => "nHuyWiB7yP5Zw52FIkcQobQuGDXCTA",
          "type" => "join",
          "mode" => "active",
          "timestamp" => 1_462_629_479_859,
          "source" => %{
            "type" => "group",
            "groupId" => "C4af4980629..."
          }
        }
      ]
    })

    %{handler: {HandlerTest, state}} = :sys.get_state(webhook)
    assert state == %{akey: :value}
  end
end
