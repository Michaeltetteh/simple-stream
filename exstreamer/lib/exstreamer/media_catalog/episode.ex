defmodule Exstreamer.MediaCatalog.Episode do
  use Ecto.Schema
  import Ecto.Changeset

  schema "episodes" do
    field :title, :string
    field :number, :decimal
    
    belongs_to :file, Exstreamer.MediaCatalog.MediaFile
    belongs_to :tvshow, Exstreamer.MediaCatalog.TVShow
    
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(episode, attrs) do
    episode
    |> cast(attrs, [:title, :number, :file])
    |> validate_required([:title, :number, :file])
  end
end
