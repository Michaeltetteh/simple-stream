defmodule ExstreamerWeb.Admin.MoviesLiveTest do
  use ExstreamerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Exstreamer.MediaCatalogFixtures

  describe "authentication" do
    test "redirects unauthenticated users to login", %{conn: conn} do
      {:error, {:redirect, %{to: path}}} = live(conn, ~p"/admin/movies")
      assert path =~ "/admin/users/log_in"
    end
  end

  describe "mount (authenticated)" do
    setup :register_and_log_in_user

    test "renders the admin movies page", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/movies")
      assert html =~ "Movies"
    end

    test "renders existing movies", %{conn: conn} do
      movie = movie_fixture(%{title: "Listed Movie"})
      {:ok, _view, html} = live(conn, ~p"/admin/movies")
      assert html =~ movie.title
    end

    test "renders Add Movie link", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/movies")
      assert html =~ "Add Movie"
    end
  end

  describe "new movie form (authenticated)" do
    setup :register_and_log_in_user

    test "shows new movie form", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/admin/movies/new")
      assert html =~ "New Movie" or html =~ "Add Movie"
    end

    test "shows validation error for missing title", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/admin/movies/new")
      html =
        view
        |> form("form", %{"movie" => %{"title" => ""}})
        |> render_submit()
      assert html =~ "can&#39;t be blank" or html =~ "can't be blank"
    end
  end

  describe "edit movie form (authenticated)" do
    setup :register_and_log_in_user

    test "shows edit form with movie data", %{conn: conn} do
      movie = movie_fixture(%{title: "Editable Movie"})
      {:ok, _view, html} = live(conn, ~p"/admin/movies/#{movie.id}/edit")
      assert html =~ "Editable Movie"
    end
  end

  describe "delete movie (authenticated)" do
    setup :register_and_log_in_user

    test "deletes the movie when delete event is triggered", %{conn: conn} do
      movie = movie_fixture(%{title: "Delete Me"})
      {:ok, view, _html} = live(conn, ~p"/admin/movies")
      view |> element("button[phx-value-id='#{movie.id}']") |> render_click()
      assert_raise Ecto.NoResultsError, fn -> Exstreamer.MediaCatalog.get_movie!(movie.id) end
    end
  end
end
