defmodule TranslaTable.Repo.Migrations.CreateLangTable do
  use Ecto.Migration

  def change do
    create table("language") do
      add :name, :string, size: 20
    end
  end
end
