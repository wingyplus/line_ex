defmodule LineEx.Webhook.MixProject do
  use Mix.Project

  def project do
    [
      app: :line_ex_webhook,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:crypto, :inets, :logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:certifi, "~> 2.7"},
      {:plug, "~> 1.0"}
    ]
  end
end
