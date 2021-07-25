defmodule LineEx.WebhookPlug.MixProject do
  use Mix.Project

  def project do
    [
      app: :line_ex_webhook_plug,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.0"},
      {:jason, "~> 1.2"},
      {:line_ex_webhook, "~> 0.1", path: "../line_ex_webhook"}
    ]
  end
end
