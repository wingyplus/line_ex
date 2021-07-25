defmodule LineEx.Webhook.HttpcClient do
  @moduledoc """
  Http client using :httpc.
  """

  def post(url, channel_access_token, payload) do
    headers = [
      {String.to_charlist("authorization"), String.to_charlist("Bearer #{channel_access_token}")}
    ]

    {:ok, {{_, status, _}, headers, body}} =
      :httpc.request(
        :post,
        {url, headers, String.to_charlist("application/json"), Jason.encode!(payload)},
        [ssl: [verify: :verify_peer, cacerts: :certifi.cacerts()]],
        sync: true,
        body_format: :binary
      )

    {status, headers, body}
  end
end
