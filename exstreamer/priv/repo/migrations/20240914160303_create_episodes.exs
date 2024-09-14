defmodule Exstreamer.Repo.Migrations.CreateEpisodes do
  use Ecto.Migration




  def change do
    create table(:tvshows) do
      add :title, :string, null: false
      add :description, :string, null: false
      add :rating, :decimal
      add :poster, :string, null: false

      add :uploaded_by, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end
      create unique_index(:tvshows, [:title])

    create table(:episodes) do
      add :title, :string
      add :number, :decimal
      
      add :file, references(:files, on_delete: :delete_all)
      add :tvshow_id, references(:tvshows)

      timestamps(type: :utc_datetime)
    end

    create index(:episodes, [:file])
    create unique_index(:episodes, [:title, :number, :file])
  end
end
