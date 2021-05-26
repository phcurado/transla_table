import Config

config :transla_table, :ecto_repos, [TranslaTable.Repo]

config :transla_table, :config, locale_schema: TranslaTable.Fixture.Schema.Lang

config :transla_table, TranslaTable.Repo,
  username: "postgres",
  password: "postgres",
  database: "translatable_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
