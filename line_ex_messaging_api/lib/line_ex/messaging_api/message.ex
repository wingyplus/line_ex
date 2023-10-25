defmodule LineEx.MessagingApi.Message do
  @moduledoc """
  APIs provided by LINE Message API.
  """

  @type reply_token() :: String.t()
  @type user_id() :: String.t()
  @type message() :: map()
  @type request() :: Tesla.option()
  @type channel_access_token() :: String.t()
  @type client() :: Tesla.Client.t()

  @doc """
  Create a request to send reply message.
  """
  @spec reply_message(reply_token(), messages :: [message()]) :: request()
  def reply_message(reply_token, messages) do
    [
      method: :post,
      url: "/v2/bot/message/reply",
      body: %{
        replyToken: reply_token,
        messages: messages
      }
    ]
  end

  @doc """
  Create a request to send push message.
  """
  @spec push_message(to :: user_id(), messages :: [message()]) :: request()
  def push_message(to, messages) do
    [
      method: :post,
      url: "/v2/bot/message/push",
      body: %{
        to: to,
        messages: messages
      }
    ]
  end

  @doc """
  Create a request to send multicast message.
  """
  @spec multicast_message(to :: [user_id()], messages :: [message()]) :: request()
  def multicast_message(to, messages) do
    [
      method: :post,
      url: "/v2/bot/message/multicast",
      body: %{
        to: to,
        messages: messages
      }
    ]
  end

  @doc """
  Create a request to send broadcast message.
  """
  @spec broadcast_message(messages :: [message()]) :: request()
  def broadcast_message(messages) do
    [
      method: :post,
      url: "/v2/bot/message/broadcast",
      body: %{
        messages: messages
      }
    ]
  end

  @doc """
  Get limit additional messages of this month.
  """
  def get_messages_quota() do
    [
      method: :get,
      url: "/v2/bot/message/quota"
    ]
  end

  @doc """
  Get current number of messages sent in this month.
  """
  def get_quota_consumption() do
    [
      method: :get,
      url: "/v2/bot/message/quota/consumption"
    ]
  end

  @doc """
  Get number of messages sent by `send_reply_message/1`. Specify `date` to
  get on specific date (default is `Date.utc_today/1`).
  """
  def get_message_delivery_reply(date \\ Date.utc_today()) do
    [
      method: :get,
      url: "/v2/bot/message/delivery/reply",
      query: [date: Calendar.strftime(date, "%Y%m%d")]
    ]
  end

  @doc """
  Get number of messages sent by `send_push_message/1`. Specify `date` to
  get on specific date (default is `Date.utc_today/1`).
  """
  def get_message_delivery_push(date \\ Date.utc_today()) do
    [
      method: :get,
      url: "/v2/bot/message/delivery/push",
      query: [date: Calendar.strftime(date, "%Y%m%d")]
    ]
  end

  @doc """
  Get number of messages sent by `send_multicast_message/1`. Specify `date` to
  get on specific date (default is `Date.utc_today/1`).
  """
  def get_message_delivery_multicast(date \\ Date.utc_today()) do
    [
      method: :get,
      url: "/v2/bot/message/delivery/multicast",
      query: [date: Calendar.strftime(date, "%Y%m%d")]
    ]
  end

  @doc """
  Get number of messages sent by `send_broadcast_message/1`. Specify `date` to
  get on specific date (default is `Date.utc_today/1`).
  """
  def get_message_delivery_broadcast(date \\ Date.utc_today()) do
    [
      method: :get,
      url: "/v2/bot/message/delivery/broadcast",
      query: [date: Calendar.strftime(date, "%Y%m%d")]
    ]
  end

  @doc """
  Get images, videos, and files sent by users.
  """
  def get_content(message_id) do
    [
      method: :get,
      url: "/v2/bot/message/#{message_id}/content"
    ]
  end

  @doc """
  Sending a `request` to LINE Server.
  """
  @deprecated "Use LineEx.MessagingApi.request/3 instead."
  @spec request(client(), request(), keyword()) :: {:ok, term()} | {:error, term()}
  def request(client, request, opts \\ []) do
    client
    |> Tesla.request(Keyword.put(request, :opts, opts))
    |> case do
      {:ok, %Tesla.Env{body: response, status: 200}} ->
        {:ok, response}

      {:ok, %Tesla.Env{body: response, status: status}} when status in [400, 404, 500] ->
        {:error, response}

      {:ok, %Tesla.Env{status: 401}} ->
        {:error, :unauthorized}

      {:ok, %Tesla.Env{status: 403}} ->
        {:error, :forbidden}
    end
  end

  @doc """
  Creating messaging api client.

  ## Options

  * `:api_endpoint` - LINE api endpoint (default is `"https://api.line.me"`).
  * `:timeout` - request timeout in milliseconds (default is `1_000`).
  """
  @spec client(channel_access_token(), [option]) :: client()
        when option: {:api_endpoint, String.t()} | {:timeout, non_neg_integer()}
  def client(channel_access_token, opts \\ []) do
    middleware =
      LineEx.MessagingApi.default_middleware(opts) ++
        [
          LineEx.MessagingApi.authentication_middleware(channel_access_token),
          Tesla.Middleware.JSON
        ]

    Tesla.client(middleware)
  end
end
