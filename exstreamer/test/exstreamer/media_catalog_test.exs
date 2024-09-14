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

  describe "files" do
    alias Exstreamer.MediaCatalog.MediaFile

    import Exstreamer.MediaCatalogFixtures

    @invalid_attrs %{name: nil, size: nil, type: nil, path: nil}

    test "list_files/0 returns all files" do
      media_file = media_file_fixture()
      assert MediaCatalog.list_files() == [media_file]
    end

    test "get_media_file!/1 returns the media_file with given id" do
      media_file = media_file_fixture()
      assert MediaCatalog.get_media_file!(media_file.id) == media_file
    end

    test "create_media_file/1 with valid data creates a media_file" do
      valid_attrs = %{name: "some name", size: 42, type: "some type", path: "some path"}

      assert {:ok, %MediaFile{} = media_file} = MediaCatalog.create_media_file(valid_attrs)
      assert media_file.name == "some name"
      assert media_file.size == 42
      assert media_file.type == "some type"
      assert media_file.path == "some path"
    end

    test "create_media_file/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = MediaCatalog.create_media_file(@invalid_attrs)
    end

    test "update_media_file/2 with valid data updates the media_file" do
      media_file = media_file_fixture()
      update_attrs = %{name: "some updated name", size: 43, type: "some updated type", path: "some updated path"}

      assert {:ok, %MediaFile{} = media_file} = MediaCatalog.update_media_file(media_file, update_attrs)
      assert media_file.name == "some updated name"
      assert media_file.size == 43
      assert media_file.type == "some updated type"
      assert media_file.path == "some updated path"
    end

    test "update_media_file/2 with invalid data returns error changeset" do
      media_file = media_file_fixture()
      assert {:error, %Ecto.Changeset{}} = MediaCatalog.update_media_file(media_file, @invalid_attrs)
      assert media_file == MediaCatalog.get_media_file!(media_file.id)
    end

    test "delete_media_file/1 deletes the media_file" do
      media_file = media_file_fixture()
      assert {:ok, %MediaFile{}} = MediaCatalog.delete_media_file(media_file)
      assert_raise Ecto.NoResultsError, fn -> MediaCatalog.get_media_file!(media_file.id) end
    end

    test "change_media_file/1 returns a media_file changeset" do
      media_file = media_file_fixture()
      assert %Ecto.Changeset{} = MediaCatalog.change_media_file(media_file)
    end
  end
end
