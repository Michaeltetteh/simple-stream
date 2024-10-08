defmodule Exstreamer.MediaCatalog.Movie do
  use Ecto.Schema
  import Ecto.Changeset

  alias Exstreamer.MediaCatalog.Category

  schema "movies" do
    field :description, :string
    field :title, :string
    field :rating, :decimal
    field :poster, :string

    many_to_many :categories, Category, join_through: "movie_categories", on_replace: :delete
    belongs_to :uploaded_by, Exstreamer.Accounts.User
    belongs_to :file_id, Exstreamer.MediaCatalog.MediaFile


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(movie, attrs) do
    movie
    |> cast(attrs, [:title, :categories, :rating, :description, :poster, :file_id])
    |> validate_required([:title, :categories, :rating, :description, :poster, :file_id])
  end
end
