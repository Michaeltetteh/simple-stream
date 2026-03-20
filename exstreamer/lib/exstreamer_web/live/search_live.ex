defmodule ExstreamerWeb.SearchLive do
  use ExstreamerWeb, :live_view

  alias Exstreamer.MediaCatalog

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Search")
     |> assign(:query, "")
     |> assign(:movies, [])
     |> assign(:series, [])
     |> assign(:searched, false),
     layout: {ExstreamerWeb.Layouts, :streaming}}
  end

  @impl true
  def handle_params(%{"q" => q}, _uri, socket) when q != "" do
    movies = MediaCatalog.search_movies(q)
    series = MediaCatalog.search_tv_series(q)

    {:noreply,
     socket
     |> assign(:query, q)
     |> assign(:movies, movies)
     |> assign(:series, series)
     |> assign(:searched, true)}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"q" => q}, socket) do
    {:noreply, push_patch(socket, to: ~p"/search?q=#{q}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-5xl mx-auto px-6 py-12">
      <h1 class="text-3xl font-black text-white mb-6">Search</h1>

      <.search_bar value={@query} class="max-w-lg mb-10" placeholder="Search movies, series..." />

      <%= if @searched do %>
        <% total = length(@movies) + length(@series) %>
        <%= if total == 0 do %>
          <div class="text-center py-16 text-gray-500">
            <p class="text-lg">No results for "<%= @query %>"</p>
          </div>
        <% else %>
          <p class="text-gray-500 text-sm mb-6"><%= total %> result(s) for "<%= @query %>"</p>

          <%= if length(@movies) > 0 do %>
            <.content_row
              title="Movies"
              items={@movies}
              href_fn={fn m -> ~p"/movies/#{m.id}" end}
            />
          <% end %>

          <%= if length(@series) > 0 do %>
            <.content_row
              title="TV Series"
              items={@series}
              href_fn={fn s -> ~p"/series/#{s.id}" end}
            />
          <% end %>
        <% end %>
      <% else %>
        <div class="text-center py-20 text-gray-600">
          <svg xmlns="http://www.w3.org/2000/svg" class="w-16 h-16 mx-auto mb-4 opacity-30" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M21 21l-4.35-4.35M17 11A6 6 0 1 1 5 11a6 6 0 0 1 12 0z"/>
          </svg>
          <p>Start typing to search movies and series</p>
        </div>
      <% end %>
    </div>
    """
  end
end
