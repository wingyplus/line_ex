defmodule LineEx.Webhook.BodyReader do
  @moduledoc """
  Read and cache request body. Uses together with `Plug.Parsers`.

  # Examples

  Uses with `Plug.Parsers`.

      ```
      plug Plug.Parsers
        parsers: [:json],
        body_reader: {LineEx.Webhook.BodyReader, :read_body, []},
        json_decoder: Jason
      ```
  """

  alias Plug.Conn

  @doc false
  def read_body(%Plug.Conn{} = conn, _opts) do
    with {:ok, body, conn} <- Conn.read_body(conn) do
      conn = Conn.put_private(conn, :raw_body, body)
      {:ok, body, conn}
    end
  end
end
