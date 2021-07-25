defmodule LineEx.Webhook do
  @moduledoc false

  use GenServer

  # TODO: add type spec each event.

  @type message_event() :: map()
  @type unsend_event() :: map()
  @type follow_event() :: map()
  @type unfollow_event() :: map()
  @type join_event() :: map()
  @type leave_event() :: map()
  @type member_join_event() :: map()
  @type member_leave_event() :: map()
  @type postback_event() :: map()
  @type video_viewing_complete_event() :: map()

  @type webhook_event() ::
          message_event()
          | unsend_event()
          | follow_event()
          | unfollow_event()
          | join_event()
          | leave_event()
          | member_join_event()
          | member_leave_event()
          | postback_event()
          | video_viewing_complete_event()

  @doc """
  Initialize state of webhook.
  """
  @callback init(opts) :: {:ok, state} | {:stop, reason}
            when opts: term(), state: term(), reason: term()

  @doc """
  Handle webhook event.
  """
  @callback handle_event(webhook_event(), state) ::
              {:reply, reply_token, [message], new_state} | {:noreply, new_state}
            when reply_token: String.t(), message: map(), state: term(), new_state: term()

  @type t() :: %__MODULE__{
          mod: module(),
          state: term(),
          channel_access_token: String.t(),
          http_client: LineEx.Webhook.HttpClient,
          line_api_url: String.t()
        }

  defstruct [
    :mod,
    :state,
    :channel_access_token,
    :http_client,
    :line_api_url
  ]

  ## Client

  def start_link(module, args, opts \\ []) when is_atom(module) and is_list(opts) do
    webhook_args = args |> Keyword.put(:mod, module) |> Keyword.put(:init_args, args)
    GenServer.start_link(__MODULE__, webhook_args, opts)
  end

  def handle_event(webhook, event) do
    GenServer.cast(webhook, {:"$webhook_event", event})
  end

  ## Server

  # TODO: validate opt here.
  @impl true
  def init(opts) do
    mod = opts[:mod]

    case mod.init(opts[:init_args]) do
      {:ok, state} ->
        {:ok,
         %__MODULE__{
           mod: mod,
           state: state,
           channel_access_token: opts[:channel_access_token],
           http_client: opts[:http_client] || LineEx.Webhook.HttpcClient,
           line_api_url: opts[:line_api_url] || "https://api.line.me"
         }}

      {:stop, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_cast({:"$webhook_event", event}, webhook) do
    channel_access_token = webhook.channel_access_token
    http_client = webhook.http_client
    endpoint = "#{webhook.line_api_url}/v2/bot/message/reply"

    new_state =
      case webhook.mod.handle_event(event, webhook.state) do
        {:reply, reply_token, messages, new_state} ->
          payload = %{
            replyToken: reply_token,
            messages: messages
          }

          {200, _, _} = http_client.post(endpoint, channel_access_token, payload)
          new_state

        {:noreply, new_state} ->
          new_state
      end

    {:noreply, %{webhook | state: new_state}}
  end

  ## Behaviour

  defmacro __using__(opts) do
    quote location: :keep, bind_quoted: [opts: opts] do
      @behaviour LineEx.Webhook

      def child_spec(init_args) do
        default = %{
          id: __MODULE__,
          start: {__MODULE__, :start_link, [init_args]}
        }

        Supervisor.child_spec(default, unquote(Macro.escape(opts)))
      end

      defoverridable child_spec: 1
    end
  end
end
