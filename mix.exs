defmodule TranslaTable.MixProject do
  use Mix.Project

  @source_url "https://github.com/phcurado/transla_table"
  @version "0.3.1"

  def project do
    [
      app: :transla_table,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps(),
      aliases: aliases(),
      preferred_cli_env: [
        test: :test,
        "ecto.gen.migration": :test
      ],
      name: "TranslaTable",
      description: "TranslaTable is a library for helping create translation schemas.",
      docs: docs(),
      package: package(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        plt_add_apps: [:ex_unit, :mix]
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
      {:ecto_sql, "~> 3.11"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:postgrex, "~> 0.17", only: [:test]},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

  defp docs do
    [
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["README.md"]
    ]
  end

  defp package() do
    [
      maintainers: ["Paulo Curado"],
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/phcurado/transla_table"},
      files: ~w(.formatter.exs mix.exs README.md lib)
    ]
  end
end
