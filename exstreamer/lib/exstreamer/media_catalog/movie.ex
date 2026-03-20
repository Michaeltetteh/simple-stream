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
    belongs_to :uploader, Exstreamer.Accounts.User, foreign_key: :uploaded_by
    belongs_to :file, Exstreamer.MediaCatalog.MediaFile, foreign_key: :file_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(movie, attrs) do
    movie
    |> cast(attrs, [:title, :rating, :description, :poster, :file_id, :uploaded_by])
    |> validate_required([:title])
  end
end
