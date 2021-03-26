defmodule TranslaTable.Repo.Migrations.CreatePostTranslationTable do
  use Ecto.Migration

  def change do
    create table("post_translation", primary_key: false) do
      add :post_id, references(:post, on_delete: :delete_all), primary_key: true
      add :language_id, references(:language, on_delete: :delete_all), primary_key: true
      add :title, :string, size: 40
      add :description, :string, size: 255
      add :slug, :string, size: 20

      timestamps()
    end
  end
end
