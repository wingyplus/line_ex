defmodule LineEx.Webhook.MixProject do
  use Mix.Project

  def project do
    [
      app: :line_ex_webhook,
      version: "0.1.0",
      elixir: "~> 1.12",
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
      {:jason, "~> 1.2"},
      {:certifi, "~> 2.7"},
      {:plug, "~> 1.0"},
      {:bypass, "~> 2.1", only: :test}
    ]
  end
end
