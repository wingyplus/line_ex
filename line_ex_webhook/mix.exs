defmodule LineEx.Webhook.MixProject do
  use Mix.Project

  @version "0.1.0-dev"

  def project do
    [
      app: :line_ex_webhook,
      version: @version,
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:crypto, :inets, :logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:telemetry, "~> 1.0"},
      {:plug, "~> 1.0"},
      {:line_ex_messaging_api, "~> 0.1.0-dev", path: "../line_ex_messaging_api"},
      {:bypass, "~> 2.1", only: :test},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false}
    ]
  end
end
