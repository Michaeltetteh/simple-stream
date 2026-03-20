defmodule ExstreamerWeb.SeriesDetailLive do
  use ExstreamerWeb, :live_view

  alias Exstreamer.MediaCatalog

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    series = MediaCatalog.get_tv_series!(id)
    first_season = List.first(series.seasons)

    {:ok,
     socket
     |> assign(:page_title, series.title)
     |> assign(:series, series)
     |> assign(:active_season, first_season)
     |> assign(:active_season_id, first_season && first_season.id),
     layout: {ExstreamerWeb.Layouts, :streaming}}
  end

  @impl true
  def handle_event("select_season", %{"id" => id}, socket) do
    season_id = String.to_integer(id)
    season = Enum.find(socket.assigns.series.seasons, &(&1.id == season_id))
    {:noreply, socket |> assign(:active_season, season) |> assign(:active_season_id, season_id)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <%!-- Series header --%>
    <div class="relative w-full h-72 sm:h-96 overflow-hidden">
      <div class="absolute inset-0 hero-banner"
           style={"background-image: url('/stream/poster/#{Path.basename(@series.poster || "")}');"}>
      </div>
      <div class="absolute inset-0 bg-gradient-to-t from-gray-900 via-gray-900/60 to-transparent"></div>
    </div>

    <div class="px-6 -mt-16 relative z-10">
      <div class="flex flex-col md:flex-row gap-8 max-w-5xl">
        <div class="flex-shrink-0 w-32 sm:w-44 rounded-lg overflow-hidden shadow-2xl ring-1 ring-gray-700">
          <%= if @series.poster && @series.poster != "" do %>
            <img src={"/stream/poster/#{Path.basename(@series.poster)}"} alt={@series.title} class="w-full aspect-[2/3] object-cover"/>
          <% else %>
            <div class="w-full aspect-[2/3] bg-gray-800 flex items-center justify-center text-gray-600">
              <svg xmlns="http://www.w3.org/2000/svg" class="w-10 h-10" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M9.75 17L9 20l-1 1h8l-1-1-.75-3M3 13h18M5 17h14a2 2 0 002-2V5a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/></svg>
            </div>
          <% end %>
        </div>

        <div class="flex-1 min-w-0 pt-4">
          <h1 class="text-2xl sm:text-3xl font-black text-white leading-tight"><%= @series.title %></h1>
          <div class="flex flex-wrap items-center gap-3 mt-2">
            <%= if @series.rating do %>
              <.rating_badge rating={@series.rating} />
            <% end %>
            <span class="text-gray-400 text-sm"><%= length(@series.seasons) %> Season(s)</span>
            <%= for cat <- @series.categories do %>
              <.category_badge category={cat} href={"#{~p"/series"}?category=#{cat.id}"} />
            <% end %>
          </div>
          <%= if @series.description do %>
            <p class="text-gray-300 text-sm leading-relaxed mt-4 max-w-xl"><%= @series.description %></p>
          <% end %>
        </div>
      </div>

      <%!-- Season selector --%>
      <%= if length(@series.seasons) > 0 do %>
        <div class="mt-8 max-w-5xl">
          <div class="flex gap-2 flex-wrap mb-6">
            <%= for season <- @series.seasons do %>
              <button
                phx-click="select_season"
                phx-value-id={season.id}
                class={"px-4 py-1.5 rounded-full text-sm font-semibold transition-colors #{if @active_season_id == season.id, do: "bg-accent text-white", else: "bg-gray-800 text-gray-300 hover:bg-gray-700"}"}
              >
                Season <%= season.season_no %>
              </button>
            <% end %>
          </div>

          <%!-- Episodes list --%>
          <%= if @active_season do %>
            <div class="flex flex-col md:flex-row gap-6">
              <div class="w-full md:w-64 flex-shrink-0">
                <h3 class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-3">
                  Season <%= @active_season.season_no %> · <%= length(@active_season.episodes) %> Episodes
                </h3>
                <div class="space-y-1">
                  <%= for episode <- @active_season.episodes do %>
                    <.episode_item
                      episode={episode}
                      href={~p"/series/#{@series.id}/season/#{@active_season.id}/episode/#{episode.id}"}
                    />
                  <% end %>
                  <%= if Enum.empty?(@active_season.episodes) do %>
                    <p class="text-gray-500 text-sm px-3">No episodes yet.</p>
                  <% end %>
                </div>
              </div>

              <%!-- Season poster --%>
              <div class="flex-1">
                <%= if @active_season.poster && @active_season.poster != "" do %>
                  <img
                    src={"/stream/poster/#{Path.basename(@active_season.poster)}"}
                    alt={"Season #{@active_season.season_no}"}
                    class="w-full max-w-sm rounded-lg object-cover"
                  />
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      <% else %>
        <div class="mt-8 text-gray-500 text-sm">No seasons available yet.</div>
      <% end %>
    </div>
    """
  end
end
