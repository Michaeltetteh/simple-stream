defmodule ExstreamerWeb.Admin.DashboardLive do
  use ExstreamerWeb, :live_view

  alias Exstreamer.MediaCatalog
  alias Exstreamer.Category

  @impl true
  def mount(_params, _session, socket) do
    movies = MediaCatalog.list_movies()
    series = MediaCatalog.list_tv_series()
    categories = Category.list_categories()

    episode_count = MediaCatalog.count_episodes()

    {:ok,
     socket
     |> assign(:page_title, "Dashboard")
     |> assign(:movie_count, length(movies))
     |> assign(:series_count, length(series))
     |> assign(:category_count, length(categories))
     |> assign(:episode_count, episode_count)
     |> assign(:recent_movies, Enum.take(movies, 5))
     |> assign(:recent_series, Enum.take(series, 5)),
     layout: {ExstreamerWeb.Layouts, :admin}}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <h2 class="text-xl font-bold text-white mb-6">Overview</h2>

      <%!-- Stat cards --%>
      <div class="grid grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
        <.stat_card title="Movies" value={@movie_count} icon="hero-film-mini" color="text-blue-400" />
        <.stat_card title="TV Series" value={@series_count} icon="hero-tv-mini" color="text-purple-400" />
        <.stat_card title="Episodes" value={@episode_count} icon="hero-play-mini" color="text-green-400" />
        <.stat_card title="Categories" value={@category_count} icon="hero-tag-mini" color="text-yellow-400" />
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <%!-- Recent movies --%>
        <div class="bg-gray-850 rounded-xl p-5 border border-gray-800">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-sm font-semibold text-gray-300">Recent Movies</h3>
            <a href={~p"/admin/movies"} class="text-xs text-accent hover:underline">View all</a>
          </div>
          <div class="space-y-3">
            <%= for movie <- @recent_movies do %>
              <div class="flex items-center gap-3">
                <div class="w-9 h-9 rounded bg-gray-800 flex-shrink-0 overflow-hidden">
                  <%= if movie.poster && movie.poster != "" do %>
                    <img src={"/stream/poster/#{Path.basename(movie.poster)}"} class="w-full h-full object-cover"/>
                  <% end %>
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm text-white truncate"><%= movie.title %></p>
                  <%= if movie.rating do %>
                    <p class="text-xs text-yellow-500">★ <%= Decimal.to_string(movie.rating) %></p>
                  <% end %>
                </div>
                <a href={~p"/admin/movies/#{movie.id}/edit"} class="text-xs text-gray-500 hover:text-gray-300">Edit</a>
              </div>
            <% end %>
            <%= if Enum.empty?(@recent_movies) do %>
              <p class="text-gray-600 text-sm">No movies yet. <a href={~p"/admin/movies/new"} class="text-accent hover:underline">Add one →</a></p>
            <% end %>
          </div>
        </div>

        <%!-- Recent series --%>
        <div class="bg-gray-850 rounded-xl p-5 border border-gray-800">
          <div class="flex items-center justify-between mb-4">
            <h3 class="text-sm font-semibold text-gray-300">Recent TV Series</h3>
            <a href={~p"/admin/series"} class="text-xs text-accent hover:underline">View all</a>
          </div>
          <div class="space-y-3">
            <%= for s <- @recent_series do %>
              <div class="flex items-center gap-3">
                <div class="w-9 h-9 rounded bg-gray-800 flex-shrink-0 overflow-hidden">
                  <%= if s.poster && s.poster != "" do %>
                    <img src={"/stream/poster/#{Path.basename(s.poster)}"} class="w-full h-full object-cover"/>
                  <% end %>
                </div>
                <div class="flex-1 min-w-0">
                  <p class="text-sm text-white truncate"><%= s.title %></p>
                  <p class="text-xs text-gray-500"><%= length(s.seasons) %> season(s)</p>
                </div>
                <a href={~p"/admin/series/#{s.id}/edit"} class="text-xs text-gray-500 hover:text-gray-300">Edit</a>
              </div>
            <% end %>
            <%= if Enum.empty?(@recent_series) do %>
              <p class="text-gray-600 text-sm">No series yet. <a href={~p"/admin/series/new"} class="text-accent hover:underline">Add one →</a></p>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp stat_card(assigns) do
    ~H"""
    <div class="bg-gray-850 rounded-xl p-5 border border-gray-800">
      <div class="flex items-start justify-between">
        <div>
          <p class="text-xs text-gray-500 uppercase tracking-wider"><%= @title %></p>
          <p class="text-3xl font-black text-white mt-1"><%= @value %></p>
        </div>
        <span class={"#{@color}"}><.icon name={@icon} class="w-6 h-6"/></span>
      </div>
    </div>
    """
  end
end
