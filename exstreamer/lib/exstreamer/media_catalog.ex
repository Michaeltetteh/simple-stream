defmodule Exstreamer.MediaCatalog do
  @moduledoc """
  The MediaCatalog context.
  """

  import Ecto.Query, warn: false
  alias Exstreamer.Repo

  alias Exstreamer.MediaCatalog.Movie

  @doc """
  Returns the list of movies.

  ## Examples

      iex> list_movies()
      [%Movie{}, ...]

  """
  def list_movies do
    Repo.all(Movie)
  end

  @doc """
  Gets a single movie.

  Raises `Ecto.NoResultsError` if the Movie does not exist.

  ## Examples

      iex> get_movie!(123)
      %Movie{}

      iex> get_movie!(456)
      ** (Ecto.NoResultsError)

  """
  def get_movie!(id), do: Repo.get!(Movie, id)

  @doc """
  Creates a movie.

  ## Examples

      iex> create_movie(%{field: value})
      {:ok, %Movie{}}

      iex> create_movie(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_movie(attrs \\ %{}) do
    %Movie{}
    |> Movie.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a movie.

  ## Examples

      iex> update_movie(movie, %{field: new_value})
      {:ok, %Movie{}}

      iex> update_movie(movie, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_movie(%Movie{} = movie, attrs) do
    movie
    |> Movie.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a movie.

  ## Examples

      iex> delete_movie(movie)
      {:ok, %Movie{}}

      iex> delete_movie(movie)
      {:error, %Ecto.Changeset{}}

  """
  def delete_movie(%Movie{} = movie) do
    Repo.delete(movie)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking movie changes.

  ## Examples

      iex> change_movie(movie)
      %Ecto.Changeset{data: %Movie{}}

  """
  def change_movie(%Movie{} = movie, attrs \\ %{}) do
    Movie.changeset(movie, attrs)
  end



  alias Exstreamer.MediaCatalog.MediaFile

  @doc """
  Returns the list of files.

  ## Examples

      iex> list_files()
      [%MediaFile{}, ...]

  """
  def list_files do
    Repo.all(MediaFile)
  end

  @doc """
  Gets a single media_file.

  Raises `Ecto.NoResultsError` if the Media file does not exist.

  ## Examples

      iex> get_media_file!(123)
      %MediaFile{}

      iex> get_media_file!(456)
      ** (Ecto.NoResultsError)

  """
  def get_media_file!(id), do: Repo.get!(MediaFile, id)

  @doc """
  Creates a media_file.

  ## Examples

      iex> create_media_file(%{field: value})
      {:ok, %MediaFile{}}

      iex> create_media_file(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_media_file(attrs \\ %{}) do
    %MediaFile{}
    |> MediaFile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a media_file.

  ## Examples

      iex> update_media_file(media_file, %{field: new_value})
      {:ok, %MediaFile{}}

      iex> update_media_file(media_file, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_media_file(%MediaFile{} = media_file, attrs) do
    media_file
    |> MediaFile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a media_file.

  ## Examples

      iex> delete_media_file(media_file)
      {:ok, %MediaFile{}}

      iex> delete_media_file(media_file)
      {:error, %Ecto.Changeset{}}

  """
  def delete_media_file(%MediaFile{} = media_file) do
    Repo.delete(media_file)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking media_file changes.

  ## Examples

      iex> change_media_file(media_file)
      %Ecto.Changeset{data: %MediaFile{}}

  """
  def change_media_file(%MediaFile{} = media_file, attrs \\ %{}) do
    MediaFile.changeset(media_file, attrs)
  end
end
