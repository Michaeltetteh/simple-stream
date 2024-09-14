defmodule Exstreamer.MediaCatalogTest do
  use Exstreamer.DataCase

  alias Exstreamer.MediaCatalog

  describe "movies" do
    alias Exstreamer.MediaCatalog.Movie

    import Exstreamer.MediaCatalogFixtures

    @invalid_attrs %{}

    test "list_movies/0 returns all movies" do
      movie = movie_fixture()
      assert MediaCatalog.list_movies() == [movie]
    end

    test "get_movie!/1 returns the movie with given id" do
      movie = movie_fixture()
      assert MediaCatalog.get_movie!(movie.id) == movie
    end

    test "create_movie/1 with valid data creates a movie" do
      valid_attrs = %{}

      assert {:ok, %Movie{} = movie} = MediaCatalog.create_movie(valid_attrs)
    end

    test "create_movie/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = MediaCatalog.create_movie(@invalid_attrs)
    end

    test "update_movie/2 with valid data updates the movie" do
      movie = movie_fixture()
      update_attrs = %{}

      assert {:ok, %Movie{} = movie} = MediaCatalog.update_movie(movie, update_attrs)
    end

    test "update_movie/2 with invalid data returns error changeset" do
      movie = movie_fixture()
      assert {:error, %Ecto.Changeset{}} = MediaCatalog.update_movie(movie, @invalid_attrs)
      assert movie == MediaCatalog.get_movie!(movie.id)
    end

    test "delete_movie/1 deletes the movie" do
      movie = movie_fixture()
      assert {:ok, %Movie{}} = MediaCatalog.delete_movie(movie)
      assert_raise Ecto.NoResultsError, fn -> MediaCatalog.get_movie!(movie.id) end
    end

    test "change_movie/1 returns a movie changeset" do
      movie = movie_fixture()
      assert %Ecto.Changeset{} = MediaCatalog.change_movie(movie)
    end
  end
end
