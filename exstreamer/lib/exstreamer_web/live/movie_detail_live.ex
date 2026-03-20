defmodule ExstreamerWeb.MovieDetailLive do
  use ExstreamerWeb, :live_view

  alias Exstreamer.MediaCatalog

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    movie = MediaCatalog.get_movie!(id)
    related = MediaCatalog.list_movies() |> Enum.reject(&(&1.id == movie.id)) |> Enum.take(12)

    {:ok,
     socket
     |> assign(:page_title, movie.title)
     |> assign(:movie, movie)
     |> assign(:related, related),
     layout: {ExstreamerWeb.Layouts, :streaming}}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Hero --%>
    <div class="relative w-full h-72 sm:h-96 overflow-hidden">
      <div class="absolute inset-0 hero-banner"
           style={"background-image: url('/stream/poster/#{Path.basename(@movie.poster || "")}');"}>
      </div>
      <div class="absolute inset-0 bg-gradient-to-t from-gray-900 via-gray-900/60 to-transparent"></div>
    </div>

    <div class="px-6 -mt-16 relative z-10">
      <div class="flex flex-col md:flex-row gap-8 max-w-5xl">
        <%!-- Poster --%>
        <div class="flex-shrink-0 w-32 sm:w-44 rounded-lg overflow-hidden shadow-2xl ring-1 ring-gray-700">
          <%= if @movie.poster && @movie.poster != "" do %>
            <img
              src={"/stream/poster/#{Path.basename(@movie.poster)}"}
              alt={@movie.title}
              class="w-full aspect-[2/3] object-cover"
            />
          <% else %>
            <div class="w-full aspect-[2/3] bg-gray-800 flex items-center justify-center text-gray-600">
              <svg xmlns="http://www.w3.org/2000/svg" class="w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M7 4v16M17 4v16M3 8h4m10 0h4M3 16h4m10 0h4M4 20h16a1 1 0 001-1V5a1 1 0 00-1-1H4a1 1 0 00-1 1v14a1 1 0 001 1z"/></svg>
            </div>
          <% end %>
        </div>

        <%!-- Info --%>
        <div class="flex-1 min-w-0 pt-4">
          <h1 class="text-2xl sm:text-3xl font-black text-white leading-tight"><%= @movie.title %></h1>

          <div class="flex flex-wrap items-center gap-3 mt-2">
            <%= if @movie.rating do %>
              <.rating_badge rating={@movie.rating} />
            <% end %>
            <%= for cat <- @movie.categories do %>
              <.category_badge category={cat} href={"#{~p"/movies"}?category=#{cat.id}"} />
            <% end %>
          </div>

          <%= if @movie.description do %>
            <p class="text-gray-300 text-sm leading-relaxed mt-4 max-w-xl"><%= @movie.description %></p>
          <% end %>
        </div>
      </div>

      <%!-- Video Player --%>
      <div class="mt-8 max-w-5xl">
        <%= if @movie.file do %>
          <.video_player file_id={@movie.file_id} title={@movie.title} class="shadow-2xl" />
        <% else %>
          <div class="aspect-[16/9] bg-gray-850 rounded-lg flex items-center justify-center text-gray-600">
            <div class="text-center">
              <svg xmlns="http://www.w3.org/2000/svg" class="w-12 h-12 mx-auto mb-2" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M15 10l4.553-2.277A1 1 0 0121 8.677V15.32a1 1 0 01-1.447.894L15 14M3 8a2 2 0 012-2h8a2 2 0 012 2v8a2 2 0 01-2 2H5a2 2 0 01-2-2V8z"/>
              </svg>
              <p>No video file attached</p>
            </div>
          </div>
        <% end %>
      </div>

      <%!-- Related movies --%>
      <%= if length(@related) > 0 do %>
        <div class="mt-12">
          <.content_row
            title="You Might Also Like"
            items={@related}
            href_fn={fn m -> ~p"/movies/#{m.id}" end}
          />
        </div>
      <% end %>
    </div>
    """
  end
end
