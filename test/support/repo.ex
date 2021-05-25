defmodule TranslaTable.Repo do
  use Ecto.Repo,
    otp_app: :transla_table,
    adapter: Ecto.Adapters.Postgres
end
