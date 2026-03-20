defmodule ExstreamerWeb.StreamingComponents do
  @moduledoc """
  Reusable UI components for the public streaming interface.
  """
  use Phoenix.Component
  use ExstreamerWeb, :verified_routes

  # ── Content card ─────────────────────────────────────────────────────────────
  # Usage: <.content_card item={@movie} href={~p"/movies/#{@movie.id}"} />

  attr :item, :map, required: true
  attr :href, :string, required: true
  attr :class, :string, default: ""

  def content_card(assigns) do
    ~H"""
    <a href={@href} class={"content-card relative block rounded-md overflow-hidden bg-gray-850 cursor-pointer #{@class}"}>
      <div class="aspect-[2/3] w-40 sm:w-44 md:w-48">
        <%= if @item.poster && @item.poster != "" do %>
          <img
            src={~p"/stream/poster/#{poster_filename(@item.poster)}"}
            alt={@item.title}
            class="w-full h-full object-cover"
            loading="lazy"
          />
        <% else %>
          <div class="w-full h-full flex items-center justify-center bg-gray-800 text-gray-600">
            <svg xmlns="http://www.w3.org/2000/svg" class="w-12 h-12" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1" d="M7 4v16M17 4v16M3 8h4m10 0h4M3 16h4m10 0h4M4 20h16a1 1 0 001-1V5a1 1 0 00-1-1H4a1 1 0 00-1 1v14a1 1 0 001 1z"/>
            </svg>
          </div>
        <% end %>
      </div>

      <%!-- Hover overlay --%>
      <div class="card-overlay absolute inset-0 bg-card-gradient flex flex-col justify-end p-3">
        <p class="text-white text-xs font-semibold leading-snug line-clamp-2"><%= @item.title %></p>
        <%= if Map.get(@item, :rating) do %>
          <p class="text-yellow-400 text-xs mt-0.5">★ <%= Decimal.to_string(@item.rating) %></p>
        <% end %>
        <div class="mt-2">
          <span class="inline-flex items-center gap-1 bg-white text-gray-900 text-xs font-bold px-2 py-0.5 rounded-full">
            <svg xmlns="http://www.w3.org/2000/svg" class="w-3 h-3" viewBox="0 0 24 24" fill="currentColor">
              <path d="M8 5v14l11-7z"/>
            </svg>
            Play
          </span>
        </div>
      </div>
    </a>
    """
  end

  # ── Content row (horizontal scroll section) ──────────────────────────────────

  attr :title, :string, required: true
  attr :items, :list, required: true
  attr :href_fn, :any, required: true
  attr :class, :string, default: ""

  def content_row(assigns) do
    ~H"""
    <section class={"mb-8 #{@class}"}>
      <h2 class="text-lg font-bold text-white mb-3 px-6"><%= @title %></h2>
      <div class="content-row px-6">
        <%= for item <- @items do %>
          <.content_card item={item} href={@href_fn.(item)} />
        <% end %>
        <%= if Enum.empty?(@items) do %>
          <p class="text-gray-500 text-sm">Nothing here yet.</p>
        <% end %>
      </div>
    </section>
    """
  end

  # ── Hero banner ────────────────────────────────────────────────────────────────

  attr :item, :map, required: true
  attr :href, :string, required: true
  attr :type, :string, default: "Movie"

  def hero_banner(assigns) do
    ~H"""
    <div class="hero-banner relative w-full h-[60vh] min-h-[400px] overflow-hidden"
         style={"background-image: url('#{poster_url(@item.poster)}');"}>
      <%!-- Gradient overlay --%>
      <div class="absolute inset-0 bg-gradient-to-r from-black/85 via-black/50 to-transparent"></div>
      <div class="absolute inset-0 bg-gradient-to-t from-gray-900 via-transparent to-transparent"></div>

      <%!-- Content --%>
      <div class="relative h-full flex flex-col justify-end px-8 pb-10 max-w-lg">
        <span class="text-xs font-semibold text-accent uppercase tracking-widest mb-2"><%= @type %></span>
        <h1 class="text-3xl sm:text-4xl font-black text-white leading-tight mb-2"><%= @item.title %></h1>

        <%= if Map.get(@item, :rating) do %>
          <div class="flex items-center gap-2 mb-3">
            <span class="text-yellow-400 text-sm font-bold">★ <%= Decimal.to_string(@item.rating) %></span>
            <span class="text-gray-400 text-sm">IMDB</span>
          </div>
        <% end %>

        <%= if Map.get(@item, :description) do %>
          <p class="text-gray-300 text-sm leading-relaxed line-clamp-3 mb-4"><%= @item.description %></p>
        <% end %>

        <div class="flex items-center gap-3">
          <a href={@href}
             class="inline-flex items-center gap-2 bg-white text-gray-900 font-bold text-sm px-5 py-2.5 rounded-full hover:bg-gray-200 transition-colors">
            <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
              <path d="M8 5v14l11-7z"/>
            </svg>
            Watch Now
          </a>
          <a href={@href}
             class="inline-flex items-center gap-2 bg-white/20 text-white font-semibold text-sm px-5 py-2.5 rounded-full hover:bg-white/30 transition-colors backdrop-blur-sm border border-white/20">
            More Info
          </a>
        </div>
      </div>
    </div>
    """
  end

  # ── Video player ────────────────────────────────────────────────────────────────

  attr :file_id, :any, required: true
  attr :title, :string, default: ""
  attr :autoplay, :boolean, default: false
  attr :class, :string, default: ""

  def video_player(assigns) do
    ~H"""
    <div class={"relative bg-black rounded-lg overflow-hidden #{@class}"}>
      <video
        class="w-full aspect-[16/9]"
        controls
        preload="metadata"
        autoplay={@autoplay}
        title={@title}
      >
        <source src={~p"/stream/video/#{@file_id}"} />
        Your browser does not support HTML5 video.
      </video>
    </div>
    """
  end

  # ── Episode item (list row) ────────────────────────────────────────────────────

  attr :episode, :map, required: true
  attr :href, :string, required: true
  attr :active, :boolean, default: false

  def episode_item(assigns) do
    ~H"""
    <a href={@href}
       class={"flex items-start gap-4 p-3 rounded-lg transition-colors #{if @active, do: "bg-gray-800 ring-1 ring-accent", else: "hover:bg-gray-800/60"}"}>
      <div class="flex-shrink-0 w-10 h-10 rounded-full bg-gray-800 flex items-center justify-center text-sm font-bold text-gray-300">
        <%= @episode.number %>
      </div>
      <div class="flex-1 min-w-0">
        <p class="text-sm font-semibold text-white truncate"><%= @episode.title %></p>
        <%= if Map.get(@episode, :released_date) do %>
          <p class="text-xs text-gray-500 mt-0.5"><%= format_date(@episode.released_date) %></p>
        <% end %>
      </div>
      <svg xmlns="http://www.w3.org/2000/svg" class="w-5 h-5 text-gray-500 flex-shrink-0 mt-1" viewBox="0 0 24 24" fill="currentColor">
        <path d="M8 5v14l11-7z"/>
      </svg>
    </a>
    """
  end

  # ── Category badge ─────────────────────────────────────────────────────────────

  attr :category, :map, required: true
  attr :active, :boolean, default: false
  attr :href, :string, default: nil

  def category_badge(assigns) do
    ~H"""
    <%= if @href do %>
      <a href={@href}
         class={"inline-block px-3 py-1 rounded-full text-xs font-semibold transition-colors #{if @active, do: "bg-accent text-white", else: "bg-gray-800 text-gray-300 hover:bg-gray-700"}"}>
        <%= @category.name %>
      </a>
    <% else %>
      <span class="inline-block px-3 py-1 rounded-full text-xs font-semibold bg-gray-800 text-gray-300">
        <%= @category.name %>
      </span>
    <% end %>
    """
  end

  # ── Rating badge ───────────────────────────────────────────────────────────────

  attr :rating, :any, required: true

  def rating_badge(assigns) do
    ~H"""
    <span class="inline-flex items-center gap-1 text-yellow-400 text-sm font-bold">
      <svg xmlns="http://www.w3.org/2000/svg" class="w-4 h-4" viewBox="0 0 24 24" fill="currentColor">
        <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z"/>
      </svg>
      <%= Decimal.to_string(@rating) %>
      <span class="text-gray-500 font-normal">/ 10</span>
    </span>
    """
  end

  # ── Search bar ─────────────────────────────────────────────────────────────────

  attr :value, :string, default: ""
  attr :placeholder, :string, default: "Search movies, series..."
  attr :class, :string, default: ""

  def search_bar(assigns) do
    ~H"""
    <div class={"relative #{@class}"}>
      <svg xmlns="http://www.w3.org/2000/svg" class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
        <path stroke-linecap="round" stroke-linejoin="round" d="M21 21l-4.35-4.35M17 11A6 6 0 1 1 5 11a6 6 0 0 1 12 0z"/>
      </svg>
      <input
        type="search"
        name="q"
        value={@value}
        placeholder={@placeholder}
        phx-debounce="300"
        phx-change="search"
        class="w-full bg-gray-800/80 text-white placeholder-gray-500 border border-gray-700 rounded-full pl-9 pr-4 py-2 text-sm focus:outline-none focus:border-gray-500 focus:ring-1 focus:ring-gray-500"
      />
    </div>
    """
  end

  # ── Private helpers ────────────────────────────────────────────────────────────

  defp poster_filename(nil), do: ""
  defp poster_filename(""), do: ""
  defp poster_filename(path), do: Path.basename(path)

  defp poster_url(nil), do: ""
  defp poster_url(""), do: ""
  defp poster_url(path) do
    filename = Path.basename(path)
    "/stream/poster/#{filename}"
  end

  defp format_date(nil), do: ""
  defp format_date(%Date{} = d), do: Calendar.strftime(d, "%b %-d, %Y")
  defp format_date(other), do: to_string(other)
end
