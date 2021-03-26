defmodule TranslaTable.Repo.Migrations.CreatePostTable do
  use Ecto.Migration

  def change do
    create table("post") do
      add :title, :string, size: 40
      add :description, :string, size: 255
      add :author, :string
      add :slug, :string, size: 20

      timestamps()
    end
  end
end
