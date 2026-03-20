defmodule Exstreamer.Repo.Migrations.AddReleasedDateToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :released_date, :date
    end
  end
end
