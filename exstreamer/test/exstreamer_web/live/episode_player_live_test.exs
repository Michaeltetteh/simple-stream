defmodule ExstreamerWeb.EpisodePlayerLiveTest do
  use ExstreamerWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  defp create_series_with_episode(_context) do
    {:ok, series} = Exstreamer.MediaCatalog.create_tv_series(%{title: "Test Show"})

    {:ok, season} = Exstreamer.MediaCatalog.create_tv_show(%{
      title: "Season 1",
      description: "First season",
      poster: "/posters/s1.jpg",
      season_no: 1,
      tv_series_id: series.id
    })

    {:ok, ep1} = Exstreamer.MediaCatalog.create_episode(%{
      title: "Pilot",
      number: 1,
      tvshow_id: season.id
    })

    {:ok, ep2} = Exstreamer.MediaCatalog.create_episode(%{
      title: "Second Episode",
      number: 2,
      tvshow_id: season.id
    })

    %{series: series, season: season, episode: ep1, next_episode: ep2}
  end

  describe "mount" do
    setup :create_series_with_episode

    test "renders the episode player page", %{conn: conn, series: series, season: season, episode: ep} do
      {:ok, _view, html} = live(conn, ~p"/series/#{series.id}/season/#{season.id}/episode/#{ep.id}")
      assert html =~ ep.title
    end

    test "renders series and season breadcrumb", %{conn: conn, series: series, season: season, episode: ep} do
      {:ok, _view, html} = live(conn, ~p"/series/#{series.id}/season/#{season.id}/episode/#{ep.id}")
      assert html =~ series.title
      assert html =~ "Season #{season.season_no}"
    end

    test "renders episode number in breadcrumb", %{conn: conn, series: series, season: season, episode: ep} do
      {:ok, _view, html} = live(conn, ~p"/series/#{series.id}/season/#{season.id}/episode/#{ep.id}")
      assert html =~ "Ep. #{ep.number}"
    end

    test "shows no video message when episode has no file", %{conn: conn, series: series, season: season, episode: ep} do
      {:ok, _view, html} = live(conn, ~p"/series/#{series.id}/season/#{season.id}/episode/#{ep.id}")
      assert html =~ "No video file attached"
    end

    test "renders next episode navigation when next episode exists",
         %{conn: conn, series: series, season: season, episode: ep, next_episode: next_ep} do
      {:ok, _view, html} = live(conn, ~p"/series/#{series.id}/season/#{season.id}/episode/#{ep.id}")
      assert html =~ next_ep.title
    end

    test "does not render prev episode link for the first episode",
         %{conn: conn, series: series, season: season, episode: ep} do
      {:ok, _view, html} = live(conn, ~p"/series/#{series.id}/season/#{season.id}/episode/#{ep.id}")
      # The second episode has a prev link; the first does not output a prev link
      refute html =~ "Ep. 0"
    end

    test "renders prev episode navigation from the second episode",
         %{conn: conn, series: series, season: season, episode: ep, next_episode: next_ep} do
      {:ok, _view, html} = live(conn, ~p"/series/#{series.id}/season/#{season.id}/episode/#{next_ep.id}")
      assert html =~ ep.title
    end

    test "raises when episode does not exist", %{conn: conn, series: series, season: season} do
      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/series/#{series.id}/season/#{season.id}/episode/0")
      end
    end
  end
end
