defmodule Exstreamer.Repo.Migrations.AddTvSeriesIdToTvshows do
  use Ecto.Migration

  def change do
    alter table(:tvshows) do
      add :tv_series_id, references(:tv_series, on_delete: :delete_all)
      add :season_no, :integer, default: 1
    end

    create index(:tvshows, [:tv_series_id])
  end
end
