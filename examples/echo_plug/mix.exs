defmodule EchoPlug.MixProject do
  use Mix.Project

  def project do
    [
      app: :echo_plug,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {EchoPlug.Application, []}
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:line_ex_webhook, "~> 0.1.0", path: "../../line_ex_webhook"},
    ]
  end
end
