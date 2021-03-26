defmodule TranslaTable.Repo.Migrations.CreateTestSchema do
  use Ecto.Migration

  def change do
    create table("test_schema") do
      add :name, :string, size: 40
      add :description, :string, size: 255
      add :author, :string
      add :slug, :string, size: 20

      timestamps()
    end
  end
end
