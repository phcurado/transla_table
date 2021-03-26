import Config

config :transla_table, TranslaTable.Repo,
  username: "postgres",
  password: "postgres",
  database: "translatable_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
