defmodule LineEx.Webhook.Signature do
  @moduledoc """
  Signature verification mechanism for LINE Webhook API.
  """

  import Plug.Conn

  @doc """
  Verify `conn` request with `channel_secret`.

  ## Returns value

  Returns `:ok` with raw request body and plug connection. Or `:invalid_signature` when request 
  doesn't match with `channel_secret`.
  """
  @spec verify(Plug.Conn.t(), String.t()) :: {:ok, binary(), Plug.Conn.t()} | :invalid_signature
  def verify(conn, channel_secret) when is_binary(channel_secret) do
    signature = get_req_header(conn, "x-line-signature") |> List.first()

    with {:ok, body, conn} <- read_body(conn),
         :ok <- verify(channel_secret, signature, body) do
      {:ok, body, conn}
    else
      _ -> :invalid_signature
    end
  end

  defp verify(_channel_secret, nil, _body), do: :invalid_signature

  defp verify(channel_secret, signature, body) do
    with {:ok, decoded_signature} <- Base.decode64(signature),
         true <- secure_compare(decoded_signature, channel_secret, body) do
      :ok
    else
      _ -> :invalid_signature
    end
  end

  defp secure_compare(decoded_signature, channel_secret, body) do
    Plug.Crypto.secure_compare(
      decoded_signature,
      :crypto.mac(:hmac, :sha256, channel_secret, body)
    )
  end
end
