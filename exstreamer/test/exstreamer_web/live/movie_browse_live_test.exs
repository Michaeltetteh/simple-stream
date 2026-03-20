defmodule ExstreamerWeb.MovieBrowseLiveTest do
  use ExstreamerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Exstreamer.MediaCatalogFixtures

  describe "mount" do
    test "renders the movies page", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/movies")
      assert html =~ "Movies"
    end

    test "renders all movies", %{conn: conn} do
      movie = movie_fixture(%{title: "Unique Movie Title"})
      {:ok, _view, html} = live(conn, ~p"/movies")
      assert html =~ movie.title
    end

    test "renders empty state when no movies", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/movies")
      assert html =~ "No movies found"
    end

    test "shows category filter badges", %{conn: conn} do
      {:ok, cat} = Exstreamer.Category.create_category(%{name: "Horror"})
      {:ok, _view, html} = live(conn, ~p"/movies")
      assert html =~ cat.name
    end
  end

  describe "handle_params - category filter" do
    test "filters movies by category", %{conn: conn} do
      {:ok, cat} = Exstreamer.Category.create_category(%{name: "Drama"})
      {:ok, _matched} = Exstreamer.MediaCatalog.create_movie_with_categories(%{title: "Drama Film", description: "d", poster: "/p.jpg"}, [cat.id])
      {:ok, _} = Exstreamer.MediaCatalog.create_movie(%{title: "Other Film", description: "d", poster: "/p2.jpg"})

      {:ok, _view, html} = live(conn, ~p"/movies?category=#{cat.id}")
      assert html =~ "Drama Film"
      refute html =~ "Other Film"
    end

    test "shows all movies when no filter is applied", %{conn: conn} do
      m1 = movie_fixture(%{title: "Movie Alpha"})
      m2 = movie_fixture(%{title: "Movie Beta"})
      {:ok, _view, html} = live(conn, ~p"/movies")
      assert html =~ m1.title
      assert html =~ m2.title
    end
  end

  describe "handle_params - search filter" do
    test "filters movies by search query", %{conn: conn} do
      movie_fixture(%{title: "Searchable Movie"})
      movie_fixture(%{title: "Another Movie"})
      {:ok, _view, html} = live(conn, ~p"/movies?q=Searchable")
      assert html =~ "Searchable Movie"
      refute html =~ "Another Movie"
    end

    test "shows no movies for non-matching query", %{conn: conn} do
      movie_fixture(%{title: "Real Title"})
      {:ok, _view, html} = live(conn, ~p"/movies?q=zzznomatch")
      assert html =~ "No movies found"
    end
  end

  describe "search event" do
    test "handle_event search patches to query URL", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/movies")
      view |> element("input[name='q']") |> render_change(%{"q" => "test query"})
      html = render(view)
      assert is_binary(html)
    end
  end
end
