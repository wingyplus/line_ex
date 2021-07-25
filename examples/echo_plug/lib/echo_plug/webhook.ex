defmodule EchoPlug.Webhook do
  use LineEx.Webhook

  def start_link(args, opts \\ []) do
    name = Keyword.get(args, :name, __MODULE__)
    LineEx.Webhook.start_link(__MODULE__, args, [{:name, name} | opts])
  end

  @impl true
  def init(args) do
    {:ok, args}
  end

  @impl true
  def handle_event(%{"events" => []}, state) do
    {:noreply, state}
  end

  @impl true
  def handle_event(%{"events" => [event]}, state) do
    case event["type"] do
      "message" ->
        {:reply, event["replyToken"], [reply_message(event["message"])], state}
    end
  end

  defp reply_message(%{"text" => text, "emojis" => emojis}) do
    prefix = "You say: "

    %{
      type: "text",
      text: "#{prefix}#{emojis_placeholder(text, emojis)}",
      emojis:
        emojis
        |> Enum.map(fn emoji ->
          %{emoji | "index" => emoji["index"] + String.length(prefix)}
        end)
    }
  end

  defp reply_message(%{"text" => text}) do
    %{
      type: "text",
      text: "You say: #{text}"
    }
  end

  defp emojis_placeholder(text, emojis) do
    Enum.reduce(emojis, text, &emoji_placeholder/2)
  end

  defp emoji_placeholder(emoji, text) do
    String.replace(text, String.slice(text, emoji["index"], emoji["length"]), "$")
  end
end
