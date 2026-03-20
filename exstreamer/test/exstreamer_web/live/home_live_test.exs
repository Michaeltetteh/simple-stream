defmodule ExstreamerWeb.HomeLiveTest do
  use ExstreamerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Exstreamer.MediaCatalogFixtures

  describe "mount" do
    test "renders home page with default sections", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")
      assert html =~ "Trending Movies"
      assert html =~ "Popular Series"
    end

    test "shows empty state when no content exists", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")
      assert html =~ "No content yet"
    end

    test "renders featured movie when movies exist", %{conn: conn} do
      movie = movie_fixture(%{title: "Featured Film"})
      {:ok, _view, html} = live(conn, ~p"/")
      assert html =~ movie.title
    end

    test "renders featured series when only series exist and no movies", %{conn: conn} do
      {:ok, series} = Exstreamer.MediaCatalog.create_tv_series(%{title: "Top Series"})
      {:ok, _view, html} = live(conn, ~p"/")
      assert html =~ series.title
    end

    test "renders category rows for movies with assigned categories", %{conn: conn} do
      {:ok, cat} = Exstreamer.Category.create_category(%{name: "Action"})
      {:ok, _movie} = Exstreamer.MediaCatalog.create_movie_with_categories(%{title: "Action Hero", description: "d", poster: "/p.jpg"}, [cat.id])
      {:ok, _view, html} = live(conn, ~p"/")
      assert html =~ "Action"
    end
  end
end
