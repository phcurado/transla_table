defmodule TranslaTable.MixProject do
  use Mix.Project

  def project do
    [
      app: :transla_table,
      description: "TranslaTable is a library for helping create translation schemas.",
      version: "0.1.1",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: [
        test: :test,
        "ecto.gen.migration": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:ecto_sql, ">= 3.4.0"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:postgrex, "~> 0.15.8", only: [:test]}
    ]
  end

  defp aliases do
    [
     test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
