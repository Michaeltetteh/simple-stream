defmodule ExstreamerWeb.EpisodePlayerLive do
  use ExstreamerWeb, :live_view

  alias Exstreamer.MediaCatalog

  @impl true
  def mount(%{"series_id" => series_id, "season_id" => season_id, "episode_id" => episode_id}, _session, socket) do
    episode = MediaCatalog.get_episode!(episode_id)
    season = MediaCatalog.get_tv_show!(season_id)
    series = MediaCatalog.get_tv_series!(series_id)

    # Build ordered episode list for prev/next nav
    episodes = season.episodes
    current_idx = Enum.find_index(episodes, &(&1.id == episode.id)) || 0
    prev_ep = if current_idx > 0, do: Enum.at(episodes, current_idx - 1)
    next_ep = Enum.at(episodes, current_idx + 1)

    {:ok,
     socket
     |> assign(:page_title, "#{episode.title} · #{series.title}")
     |> assign(:episode, episode)
     |> assign(:season, season)
     |> assign(:series, series)
     |> assign(:episodes, episodes)
     |> assign(:prev_ep, prev_ep)
     |> assign(:next_ep, next_ep),
     layout: {ExstreamerWeb.Layouts, :streaming}}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-6xl mx-auto px-4 py-6">
      <%!-- Breadcrumb --%>
      <nav class="text-xs text-gray-500 mb-4 flex items-center gap-2">
        <a href={~p"/series"} class="hover:text-gray-300 transition-colors">Series</a>
        <span>/</span>
        <a href={~p"/series/#{@series.id}"} class="hover:text-gray-300 transition-colors"><%= @series.title %></a>
        <span>/</span>
        <span class="text-gray-400">Season <%= @season.season_no %></span>
        <span>/</span>
        <span class="text-white">Ep. <%= @episode.number %></span>
      </nav>

      <div class="flex flex-col lg:flex-row gap-6">
        <%!-- Main player --%>
        <div class="flex-1 min-w-0">
          <%= if @episode.file do %>
            <.video_player file_id={@episode.file} title={"#{@series.title} S#{@season.season_no}E#{@episode.number}"} autoplay={true} />
          <% else %>
            <div class="aspect-[16/9] bg-gray-850 rounded-lg flex items-center justify-center text-gray-600">
              <p>No video file attached</p>
            </div>
          <% end %>

          <div class="mt-4">
            <h1 class="text-xl font-bold text-white">
              S<%= @season.season_no %>E<%= @episode.number %> · <%= @episode.title %>
            </h1>
            <%= if @episode.released_date do %>
              <p class="text-sm text-gray-500 mt-1"><%= Calendar.strftime(@episode.released_date, "%B %-d, %Y") %></p>
            <% end %>
          </div>

          <%!-- Prev / Next nav --%>
          <div class="flex items-center justify-between mt-6 pt-4 border-t border-gray-800">
            <%= if @prev_ep do %>
              <a href={~p"/series/#{@series.id}/season/#{@season.id}/episode/#{@prev_ep.id}"}
                 class="flex items-center gap-2 text-sm text-gray-400 hover:text-white transition-colors">
                <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M15 19l-7-7 7-7"/>
                </svg>
                Ep. <%= @prev_ep.number %>: <%= @prev_ep.title %>
              </a>
            <% else %>
              <div></div>
            <% end %>

            <%= if @next_ep do %>
              <a href={~p"/series/#{@series.id}/season/#{@season.id}/episode/#{@next_ep.id}"}
                 class="flex items-center gap-2 text-sm text-gray-400 hover:text-white transition-colors">
                Ep. <%= @next_ep.number %>: <%= @next_ep.title %>
                <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M9 5l7 7-7 7"/>
                </svg>
              </a>
            <% end %>
          </div>
        </div>

        <%!-- Episode sidebar --%>
        <div class="w-full lg:w-72 flex-shrink-0">
          <h3 class="text-sm font-semibold text-gray-400 mb-3 uppercase tracking-wider">
            Season <%= @season.season_no %> Episodes
          </h3>
          <div class="space-y-1 max-h-[70vh] overflow-y-auto pr-1">
            <%= for ep <- @episodes do %>
              <.episode_item
                episode={ep}
                href={~p"/series/#{@series.id}/season/#{@season.id}/episode/#{ep.id}"}
                active={ep.id == @episode.id}
              />
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
