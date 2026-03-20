defmodule ExstreamerWeb.CategoryBrowseLiveTest do
  use ExstreamerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "mount" do
    test "renders the category browse page with category name", %{conn: conn} do
      {:ok, cat} = Exstreamer.Category.create_category(%{name: "Fantasy"})
      {:ok, _view, html} = live(conn, ~p"/categories/#{cat.id}")
      assert html =~ "Fantasy"
    end

    test "shows 'Category' label as page type indicator", %{conn: conn} do
      {:ok, cat} = Exstreamer.Category.create_category(%{name: "Thriller"})
      {:ok, _view, html} = live(conn, ~p"/categories/#{cat.id}")
      assert html =~ "Category"
    end

    test "renders movies that belong to the category", %{conn: conn} do
      {:ok, cat} = Exstreamer.Category.create_category(%{name: "Action"})
      {:ok, movie} = Exstreamer.MediaCatalog.create_movie_with_categories(%{title: "Boom Film", description: "d", poster: "/p.jpg"}, [cat.id])
      {:ok, _view, html} = live(conn, ~p"/categories/#{cat.id}")
      assert html =~ movie.title
    end

    test "does not render movies from other categories", %{conn: conn} do
      {:ok, cat} = Exstreamer.Category.create_category(%{name: "Horror"})
      {:ok, _other} = Exstreamer.MediaCatalog.create_movie(%{title: "Hidden Film", description: "d", poster: "/p.jpg"})
      {:ok, _view, html} = live(conn, ~p"/categories/#{cat.id}")
      refute html =~ "Hidden Film"
    end

    test "renders series that belong to the category", %{conn: conn} do
      {:ok, cat} = Exstreamer.Category.create_category(%{name: "Sci-Fi"})
      {:ok, series} = Exstreamer.MediaCatalog.create_tv_series_with_categories(%{title: "Space Opera"}, [cat.id])
      {:ok, _view, html} = live(conn, ~p"/categories/#{cat.id}")
      assert html =~ series.title
    end

    test "shows empty state when category has no content", %{conn: conn} do
      {:ok, cat} = Exstreamer.Category.create_category(%{name: "EmptyCat"})
      {:ok, _view, html} = live(conn, ~p"/categories/#{cat.id}")
      assert html =~ "No content in this category yet"
    end

    test "raises when category does not exist", %{conn: conn} do
      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/categories/0")
      end
    end
  end
end
