defmodule LineEx.MessagingApi.OAuth2 do
  @moduledoc """
  OAuth2 client for LINE Messaging API.
  """

  @doc """
  Issue short-lived channel access token.

  Please note that the token that issued by this function cannot
  revoke by `revoke_channel_access_totken/3`.
  """
  def issue_channel_access_token(channel_id, channel_secret)
      when is_binary(channel_id) and is_binary(channel_secret) do
    [
      method: :post,
      url: "/v2/oauth/accessToken",
      body: %{
        grant_type: "client_credentials",
        client_id: channel_id,
        client_secret: channel_secret
      }
    ]
  end

  @doc """
  Revoke channel access token.
  """
  def revoke_channel_access_token(channel_access_token, channel_id, channel_secret)
      when is_binary(channel_access_token) and is_binary(channel_id) and
             is_binary(channel_secret) do
    [
      method: :post,
      url: "/oauth2/v2.1/revoke",
      body: %{
        client_id: channel_id,
        client_secret: channel_secret,
        access_token: channel_access_token
      }
    ]
  end

  def client(opts \\ []) do
    middleware =
      LineEx.MessagingApi.default_middleware(opts) ++
        [Tesla.Middleware.DecodeJson, Tesla.Middleware.EncodeFormUrlencoded]

    Tesla.client(middleware)
  end
end
