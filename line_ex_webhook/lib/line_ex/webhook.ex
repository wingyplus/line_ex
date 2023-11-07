defmodule LineEx.Webhook do
  @moduledoc """
  A behaviour for implementing LINE webhook. When `LineEx.Webhook.Plug`
  receive an event, a plug module will verify the request and forward
  event to the webhook.

  ## Example

  Let's build a echo webhook that reply a message that user sent. We would
  create a module and use `LineEx.Webhook` behaviour:

      defmodule Echo.Webhook do
        use LineEx.Webhook

        ...
      end

  After use `LineEx.Webhook`. The module must implements 3 functions, the
  first one is `start_link/2` to starting a webhook process:

      defmodule Echo.Webhook do
        use LineEx.Webhook

        def start_link(args, opts \\ []) do
          LineEx.Webhook.start_link(__MODULE__, args, opts)
        end
      end


  The second one is `init/1`, `LineEx.Webhook` will invoke this function when initialize
  a process. The `init/1` callback must returns `{:ok, state}` or `{:stop, reason}`
  if it found an error, such as initialize argument is not valid:

      defmodule Echo.Webhook do
        use LineEx.Webhook

        def start_link(args, opts \\ []) do
          LineEx.Webhook.start_link(__MODULE__, args, opts)
        end

        @impl true
        def init(args) do
          # Processing arguments here.
          {:ok, %{}}
        end
      end

  And finally, the `handle_event/2` for handling LINE webhook event, the first argument is
  an event that LINE sent to us and the second is the state of the webhook process:

      defmodule Echo.Webhook do
        use LineEx.Webhook

        def start_link(args, opts \\ []) do
          LineEx.Webhook.start_link(__MODULE__, args, opts)
        end

        @impl true
        def init(args) do
          # Processing arguments here.
          {:ok, %{}}
        end

        @impl true
        def handle_event(event, state) do
          ...
        end
      end

  the result from this callback must be one of:

  * `{:reply, reply_token, messages, state}` - it'll tell the process to reply a `messages` to
    the user with a `reply_token`. And `state` of process. With this way, you can a lot of things
    with the webhook, such as store chat state per user to do stateful chat.

  * `{:noreply, state}` - do not reply any messages to the user.

  So our echo webhook will be like this:

      defmodule Echo.Webhook do
        use LineEx.Webhook

        def start_link(args, opts \\ []) do
          LineEx.Webhook.start_link(__MODULE__, args, opts)
        end

        @impl true
        def init(args) do
          # Processing arguments here.
          {:ok, %{}}
        end

        @impl true
        def handle_event(%{"events" => [event]}, state) do
          {:reply,
           event["replyToken"],
           [%{type: "text", text: event["message"]}],
           state}
        end
      end

  The `handle_event/2` will reply a text that user sent to the webhook. Note that we
  assume the user send text message to us. If you want to handle more kind of event,
  you can use `event["type"]` to check type of event which's follow the (LINE Webhook Event Objects)[https://developers.line.biz/en/reference/messaging-api/#webhook-event-objects]
  guideline.

  The final step, put a webhook module to the supervisor children:

      children = [
        {Echo.Webhook, channel_access_token: "..."}
        ...
      ]

  In the process arguments in `children`, set the `channel_access_token` to it to uses for reply
  a message.
  """

  use GenServer

  alias LineEx.MessagingApi.Message

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
          line_api_url: String.t()
        }

  defstruct [
    :mod,
    :state,
    :channel_access_token,
    :line_api_url
  ]

  ## Client

  @doc """
  Starting a `LineEx.Webhook` process.

  Once the process started, the `init/1` function of the given `module` is called with
  `args`.
  """
  @spec start_link(module(), term(), GenServer.options()) :: GenServer.on_start()
  def start_link(module, args, opts \\ []) when is_atom(module) and is_list(opts) do
    webhook_args = args |> Keyword.put(:mod, module) |> Keyword.put(:init_args, args)
    GenServer.start_link(__MODULE__, webhook_args, opts)
  end

  @doc """
  Handling an `event`. The `event` will process asynchronously.
  """
  @spec handle_event(GenServer.server(), webhook_event()) :: :ok
  def handle_event(webhook, event) do
    GenServer.cast(webhook, {:"$webhook_event", event})
  end

  ## Server

  # TODO: validate opt here.
  @impl true
  def init(opts) do
    mod = opts[:mod]

    case mod.init(opts[:init_args] ++ Keyword.take(opts, [:channel_access_token])) do
      {:ok, state} ->
        {:ok,
         %__MODULE__{
           mod: mod,
           state: state,
           channel_access_token: opts[:channel_access_token],
           line_api_url: opts[:line_api_url] || "https://api.line.me"
         }}

      {:stop, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_cast({:"$webhook_event", event}, webhook) do
    new_state =
      case webhook.mod.handle_event(event, webhook.state) do
        {:reply, reply_token, messages, new_state} ->
          {:ok, %{}} =
            webhook.channel_access_token
            |> resolve_value()
            |> Message.client(timeout: 10_000, api_endpoint: webhook.line_api_url)
            |> Message.request(Message.reply_message(reply_token, messages))

          new_state

        {:noreply, new_state} ->
          new_state
      end

    {:noreply, %{webhook | state: new_state}}
  end

  def resolve_value({:system, env}), do: System.get_env(env)
  def resolve_value(value), do: value

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
