defmodule LineEx.Factory do
  def build(:valid_channel_secret) do
    "<channel_secret>"
  end

  def build(:invalid_channel_secret) do
    "<invalid_channel_secret>"
  end

  def build(:valid_channel_access_token) do
    "<channel_access_token>"
  end

  def build(:message_event) do
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
