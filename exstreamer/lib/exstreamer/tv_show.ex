defmodule TvShow do
  import Ecto.Query, warn: false
  alias Exstreamer.Repo
  alias Exstreamer.MediaCatalog.Tv_show

  @doc """
  Returns the list of tv_shows.

  ## Examples

      iex> list_tv_shows()
      [%Tv_show{}, ...]

  """
  def list_tv_shows do
    Repo.all(Tv_show)
  end

  @doc """
  Gets a single tv_show.

  Raises `Ecto.NoResultsError` if the Tv show does not exist.

  ## Examples

      iex> get_tv_show!(123)
      %Tv_show{}

      iex> get_tv_show!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tv_show!(id), do: Repo.get!(Tv_show, id)

  @doc """
  Creates a tv_show.

  ## Examples

      iex> create_tv_show(%{field: value})
      {:ok, %Tv_show{}}

      iex> create_tv_show(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tv_show(attrs \\ %{}) do
    %Tv_show{}
    |> Tv_show.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tv_show.

  ## Examples

      iex> update_tv_show(tv_show, %{field: new_value})
      {:ok, %Tv_show{}}

      iex> update_tv_show(tv_show, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tv_show(%Tv_show{} = tv_show, attrs) do
    tv_show
    |> Tv_show.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tv_show.

  ## Examples

      iex> delete_tv_show(tv_show)
      {:ok, %Tv_show{}}

      iex> delete_tv_show(tv_show)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tv_show(%Tv_show{} = tv_show) do
    Repo.delete(tv_show)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tv_show changes.

  ## Examples

      iex> change_tv_show(tv_show)
      %Ecto.Changeset{data: %Tv_show{}}

  """
  def change_tv_show(%Tv_show{} = tv_show, attrs \\ %{}) do
    Tv_show.changeset(tv_show, attrs)
  end
end