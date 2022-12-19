defmodule MyApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :my_app,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MyApp.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_aws, "~> 2.1"},
      {:sweet_xml, "~> 0.6"},
      {:broadway_sqs, "~> 0.7"},
      {:aws, "~> 0.13.0"},
      {:jason, "~> 1.4"},
      {:hackney, "~> 1.9"},
      {:httpoison, "~> 1.8"}
    ]
  end
end
