defmodule Exstreamer.MediaCatalog.MediaFile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "files" do
    field :name, :string
    field :size, :integer
    field :type, :string
    field :path, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(media_file, attrs) do
    media_file
    |> cast(attrs, [:name, :path, :size, :type])
    |> validate_required([:name, :path, :size, :type])
  end
end
