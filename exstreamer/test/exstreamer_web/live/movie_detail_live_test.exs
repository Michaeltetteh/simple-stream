defmodule ExstreamerWeb.MovieDetailLiveTest do
  use ExstreamerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Exstreamer.MediaCatalogFixtures

  describe "mount" do
    test "renders the movie detail page", %{conn: conn} do
      movie = movie_fixture(%{title: "Detail Movie", description: "A great movie"})
      {:ok, _view, html} = live(conn, ~p"/movies/#{movie.id}")
      assert html =~ movie.title
    end

    test "renders movie description when present", %{conn: conn} do
      movie = movie_fixture(%{title: "Described Movie", description: "This is the description"})
      {:ok, _view, html} = live(conn, ~p"/movies/#{movie.id}")
      assert html =~ "This is the description"
    end

    test "renders no video file message when file is not attached", %{conn: conn} do
      movie = movie_fixture(%{title: "No File Movie"})
      {:ok, _view, html} = live(conn, ~p"/movies/#{movie.id}")
      assert html =~ "No video file attached"
    end

    test "renders category badges for movie categories", %{conn: conn} do
      {:ok, cat} = Exstreamer.Category.create_category(%{name: "Adventure"})
      {:ok, movie} = Exstreamer.MediaCatalog.create_movie_with_categories(%{title: "Adventure Film", description: "d", poster: "/p.jpg"}, [cat.id])
      {:ok, _view, html} = live(conn, ~p"/movies/#{movie.id}")
      assert html =~ "Adventure"
    end

    test "raises when movie id does not exist", %{conn: conn} do
      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/movies/0")
      end
    end

    test "renders related movies section", %{conn: conn} do
      main = movie_fixture(%{title: "Main Movie"})
      _related = movie_fixture(%{title: "Related Movie"})
      {:ok, _view, html} = live(conn, ~p"/movies/#{main.id}")
      assert html =~ "Related Movie"
    end
  end
end
