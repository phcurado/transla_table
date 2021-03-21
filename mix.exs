defmodule TranslaTable.MixProject do
  use Mix.Project

  def project do
    [
      app: :transla_table,
      description: "TranslaTable is a library for helping create translation schemas.",
      version: "0.1.0",
      elixir: "~> 1.11",
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
      {:ecto_sql, ">= 3.4.0"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false}
    ]
  end
end
