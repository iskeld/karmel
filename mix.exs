defmodule Karmel.MixProject do
  use Mix.Project

  def project do
    [
      app: :karmel,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Karmel.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.1"},
      {:plug, "~> 1.4"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.0"},
      {:ecto, "~> 2.2"},
      {:postgrex, "~> 0.13.5"},
      {:dialyxir, "~> 0.5", only: [:dev], runtime: false},
      {:mox, "~> 0.3.2", only: :test}
    ]
  end
end
