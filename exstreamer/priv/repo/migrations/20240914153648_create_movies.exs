defmodule Exstreamer.Repo.Migrations.CreateMovies do
  use Ecto.Migration

  def change do
    create table(:movies) do
      add :title, :string, null: false
      add :description, :string, null: false
      add :rating, :decimal
      add :poster, :string, null: false

      add :uploaded_by, references(:users, on_delete: :delete_all)
      add :file_id, references(:files, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:movies, [:file_id, :uploaded_by])
    create unique_index(:movies, [:file_id])
  end
end
