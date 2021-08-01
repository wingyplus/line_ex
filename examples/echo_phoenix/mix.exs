defmodule EchoPhoenix.MixProject do
  use Mix.Project

  def project do
    [
      app: :echo_phoenix,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {EchoPhoenix.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.5.9"},
      {:telemetry_metrics, "~> 0.4"},
      {:telemetry_poller, "~> 0.4"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:finch, "~> 0.8"},
      {:line_ex_webhook, "~> 0.1.0-dev", path: "../../line_ex_webhook"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"]
    ]
  end
end
