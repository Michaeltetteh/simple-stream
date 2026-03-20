defmodule Exstreamer.MediaCatalog.Episode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "episodes" do
    field :title, :string
    field :number, :integer
    field :released_date, :date

    belongs_to :media_file, Exstreamer.MediaCatalog.MediaFile, foreign_key: :file
    belongs_to :tvshow, Exstreamer.MediaCatalog.TVShow

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(episode, attrs) do
    episode
    |> cast(attrs, [:title, :number, :released_date, :file, :tvshow_id])
    |> validate_required([:title, :number])
  end
end
