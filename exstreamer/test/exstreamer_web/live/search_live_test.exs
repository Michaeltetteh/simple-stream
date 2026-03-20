defmodule ExstreamerWeb.SearchLiveTest do
  use ExstreamerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Exstreamer.MediaCatalogFixtures

  describe "mount - initial state" do
    test "renders search page", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/search")
      assert html =~ "Search"
    end

    test "shows prompt to start typing on initial load", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/search")
      assert html =~ "Start typing to search movies and series"
    end

    test "does not show results before a search is performed", %{conn: conn} do
      movie_fixture(%{title: "Should Not Appear Yet"})
      {:ok, _view, html} = live(conn, ~p"/search")
      refute html =~ "Should Not Appear Yet"
    end
  end

  describe "handle_params - search with query" do
    test "shows movie results matching the query", %{conn: conn} do
      movie_fixture(%{title: "FindThis Movie"})
      {:ok, _view, html} = live(conn, ~p"/search?q=FindThis")
      assert html =~ "FindThis Movie"
    end

    test "shows series results matching the query", %{conn: conn} do
      tv_series_fixture(%{title: "FindThis Show"})
      {:ok, _view, html} = live(conn, ~p"/search?q=FindThis")
      assert html =~ "FindThis Show"
    end

    test "shows result count for matching content", %{conn: conn} do
      movie_fixture(%{title: "Countable Movie"})
      {:ok, _view, html} = live(conn, ~p"/search?q=Countable")
      assert html =~ "result(s)"
    end

    test "shows no results message when nothing matches", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/search?q=zzznomatch")
      assert html =~ "No results for"
    end

    test "does not show unrelated content in results", %{conn: conn} do
      movie_fixture(%{title: "Unrelated Film"})
      {:ok, _view, html} = live(conn, ~p"/search?q=zzznomatch")
      refute html =~ "Unrelated Film"
    end
  end

  describe "handle_event search" do
    test "search event with empty query does not crash", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/search")
      html = view |> element("input[name='q']") |> render_change(%{"q" => ""})
      assert is_binary(html)
    end

    test "search event pushes patch with query param", %{conn: conn} do
      movie_fixture(%{title: "Patchable Movie"})
      {:ok, view, _html} = live(conn, ~p"/search")
      view |> element("input[name='q']") |> render_change(%{"q" => "Patchable"})
      html = render(view)
      assert html =~ "Patchable Movie"
    end
  end
end
