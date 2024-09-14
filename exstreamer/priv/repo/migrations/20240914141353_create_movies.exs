defmodule Exstreamer.Repo.Migrations.CreateMovies do
  use Ecto.Migration

  def change do
    create table(:movies) do
      add :title, :string, null: false
      add :description, :string, null: false
      add :rating, :decimal
      add :poster, :string, null: false

      add :uploaded_by, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
  end
end
