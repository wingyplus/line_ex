defmodule LineEx.Webhook.HttpClient do
  @moduledoc """
  Http client behaviour spec that uses within LineEx.Webhook.
  """

  @doc """
  Send post request to `url`.
  """
  @callback post(url, headers, request_body) :: {status, headers, response_body}
            when url: String.t(),
                 headers: list(),
                 request_body: map(),
                 status: non_neg_integer(),
                 response_body: map()
end
