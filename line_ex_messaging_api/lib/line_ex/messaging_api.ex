defmodule LineEx.MessagingApi do
  @moduledoc """
  Documentation for `LineEx.MessagingApi`.
  """

  @type request() :: Tesla.option()
  @type channel_access_token() :: String.t()
  @type client() :: Tesla.Client.t()

  @line_api_endpoint "https://api.line.me"

  @doc """
  Default middleware set uses across LINE api client.

  ## Options

  * `:api_endpoint` - LINE api endpoint (default is `"https://api.line.me"`).
  * `:timeout` - request timeout in milliseconds (default is `1_000`).
  """
  @spec default_middleware([option]) :: client()
        when option: {:api_endpoint, String.t()} | {:timeout, non_neg_integer()}
  def default_middleware(opts \\ []) do
    [
      {Tesla.Middleware.BaseUrl, Keyword.get(opts, :api_endpoint, @line_api_endpoint)},
      {Tesla.Middleware.Timeout, timeout: Keyword.get(opts, :timeout, 1_000)}
    ]
  end

  def authentication_middleware(channel_access_token) do
    {Tesla.Middleware.Headers, [{"authorization", "Bearer " <> channel_access_token}]}
  end

  @doc """
  Sending a `request` to LINE Server.

  ## Options

  * `:return_headers` - Returns HTTP request header when request it successfully.
  """
  @spec request(client(), request(), keyword()) ::
          {:ok, term()} | {:ok, term(), [header]} | {:error, term()}
        when header: {String.t(), String.t()}
  def request(client, request, opts \\ []) do
    return_headers? = opts[:return_headers] || false

    client
    |> Tesla.request(Keyword.put(request, :opts, opts))
    |> dbg()
    |> case do
      {:ok, %Tesla.Env{body: response, status: 200, headers: headers}} ->
        if return_headers? do
          {:ok, response, headers}
        else
          {:ok, response}
        end

      {:ok, %Tesla.Env{body: response, status: status}} when status in [400, 404, 500] ->
        {:error, response}

      {:ok, %Tesla.Env{status: 401}} ->
        {:error, :unauthorized}

      {:ok, %Tesla.Env{status: 403}} ->
        {:error, :forbidden}
    end
  end
end
