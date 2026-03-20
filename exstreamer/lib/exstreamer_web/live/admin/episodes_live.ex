defmodule ExstreamerWeb.Admin.EpisodesLive do
  use ExstreamerWeb, :live_view

  alias Exstreamer.MediaCatalog

  @upload_dir Application.app_dir(:exstreamer, "priv/uploads")

  @impl true
  def mount(%{"season_id" => season_id}, _session, socket) do
    season = MediaCatalog.get_tv_show!(season_id)
    episodes = MediaCatalog.list_episodes_for_season(season_id)

    {:ok,
     socket
     |> assign(:page_title, "Episodes — Season #{season.season_no}")
     |> assign(:season, season)
     |> assign(:episodes, episodes)
     |> assign(:form, nil)
     |> assign(:editing, nil)
     |> allow_upload(:video, accept: ~w(.mp4 .webm .mkv .mov), max_entries: 1, max_file_size: 5_000_000_000),
     layout: {ExstreamerWeb.Layouts, :admin}}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, %{assigns: %{live_action: :edit}} = socket) do
    episode = MediaCatalog.get_episode!(id)
    changeset = MediaCatalog.change_episode(episode)
    {:noreply, socket |> assign(:editing, episode) |> assign(:form, to_form(changeset))}
  end

  def handle_params(_params, _uri, %{assigns: %{live_action: :new}} = socket) do
    changeset = MediaCatalog.change_episode(%Exstreamer.MediaCatalog.Episode{})
    {:noreply, socket |> assign(:editing, nil) |> assign(:form, to_form(changeset))}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket |> assign(:form, nil) |> assign(:editing, nil)}
  end

  @impl true
  def handle_event("save", %{"episode" => params}, socket) do
    {:ok, file_record} = maybe_upload_video(socket, params["title"] || "episode")

    attrs =
      params
      |> Map.put("tvshow_id", socket.assigns.season.id)
      |> then(fn a -> if file_record, do: Map.put(a, "file", file_record.id), else: a end)

    result =
      case socket.assigns.editing do
        nil -> MediaCatalog.create_episode(attrs)
        episode -> MediaCatalog.update_episode(episode, attrs)
      end

    case result do
      {:ok, _} ->
        season_id = socket.assigns.season.id
        {:noreply,
         socket
         |> put_flash(:info, "Episode saved.")
         |> assign(:episodes, MediaCatalog.list_episodes_for_season(season_id))
         |> push_patch(to: ~p"/admin/seasons/#{season_id}/episodes")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    episode = MediaCatalog.get_episode!(id)
    MediaCatalog.delete_episode(episode)
    season_id = socket.assigns.season.id
    {:noreply,
     socket
     |> put_flash(:info, "Episode deleted.")
     |> assign(:episodes, MediaCatalog.list_episodes_for_season(season_id))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center gap-2 text-sm text-gray-500 mb-1">
        <a href={~p"/admin/series"} class="hover:text-gray-300">Series</a>
        <span>/</span>
        <%= if @season.tv_series do %>
          <a href={~p"/admin/series/#{@season.tv_series_id}/seasons"} class="hover:text-gray-300"><%= @season.tv_series.title %></a>
          <span>/</span>
        <% end %>
        <span class="text-gray-300">Season <%= @season.season_no %></span>
      </div>

      <div class="flex items-center justify-between mb-6">
        <h2 class="text-xl font-bold text-white">Episodes</h2>
        <.link patch={~p"/admin/seasons/#{@season.id}/episodes/new"}
              class="inline-flex items-center gap-2 bg-accent text-white text-sm font-semibold px-4 py-2 rounded-lg hover:bg-red-700 transition-colors">
          <.icon name="hero-plus-mini" class="w-4 h-4"/> Add Episode
        </.link>
      </div>

      <%= if @form do %>
        <.modal id="episode-modal" show on_cancel={JS.patch(~p"/admin/seasons/#{@season.id}/episodes")}>
          <h3 class="text-lg font-bold text-white mb-4">
            <%= if @editing, do: "Edit Episode", else: "New Episode" %>
          </h3>
          <.simple_form for={@form} phx-submit="save" class="space-y-4">
            <.input field={@form[:number]} type="number" label="Episode Number"/>
            <.input field={@form[:title]} label="Title"/>
            <.input field={@form[:released_date]} type="date" label="Release Date"/>

            <div>
              <label class="block text-sm font-medium text-gray-300 mb-1">Video File</label>
              <.live_file_input upload={@uploads.video}
                class="block text-sm text-gray-400 file:mr-3 file:py-1.5 file:px-3 file:rounded file:border-0 file:bg-gray-700 file:text-gray-300 hover:file:bg-gray-600"/>
              <%= for entry <- @uploads.video.entries do %>
                <div class="mt-2">
                  <div class="flex justify-between text-xs text-gray-500 mb-1">
                    <span><%= entry.client_name %></span>
                    <span><%= entry.progress %>%</span>
                  </div>
                  <div class="w-full bg-gray-700 rounded-full h-1">
                    <div class="bg-accent h-1 rounded-full transition-all" style={"width: #{entry.progress}%"}></div>
                  </div>
                </div>
              <% end %>
            </div>

            <:actions>
              <.button type="submit" class="bg-accent hover:bg-red-700 text-white">Save</.button>
              <.link patch={~p"/admin/seasons/#{@season.id}/episodes"} class="text-sm text-gray-400 ml-3">Cancel</.link>
            </:actions>
          </.simple_form>
        </.modal>
      <% end %>

      <div class="bg-gray-850 rounded-xl border border-gray-800 overflow-hidden">
        <table class="w-full text-sm">
          <thead class="border-b border-gray-800">
            <tr>
              <th class="text-left text-xs text-gray-500 uppercase tracking-wider px-4 py-3 w-16">#</th>
              <th class="text-left text-xs text-gray-500 uppercase tracking-wider px-4 py-3">Title</th>
              <th class="text-left text-xs text-gray-500 uppercase tracking-wider px-4 py-3 hidden md:table-cell">Released</th>
              <th class="text-left text-xs text-gray-500 uppercase tracking-wider px-4 py-3 hidden md:table-cell">Video</th>
              <th class="px-4 py-3"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-gray-800">
            <%= for episode <- @episodes do %>
              <tr class="hover:bg-gray-800/40 transition-colors">
                <td class="px-4 py-3 text-gray-400 font-mono"><%= episode.number %></td>
                <td class="px-4 py-3 font-medium text-white"><%= episode.title %></td>
                <td class="px-4 py-3 hidden md:table-cell text-gray-400 text-xs">
                  <%= if episode.released_date, do: Calendar.strftime(episode.released_date, "%b %-d, %Y") %>
                </td>
                <td class="px-4 py-3 hidden md:table-cell text-gray-500">
                  <%= if episode.file, do: "✓", else: "—" %>
                </td>
                <td class="px-4 py-3 text-right">
                  <div class="flex items-center justify-end gap-3">
                    <.link patch={~p"/admin/seasons/#{@season.id}/episodes/#{episode.id}/edit"} class="text-xs text-gray-400 hover:text-white">Edit</.link>
                    <button phx-click="delete" phx-value-id={episode.id}
                            data-confirm={"Delete Episode #{episode.number}?"}
                            class="text-xs text-red-500 hover:text-red-400">Delete</button>
                  </div>
                </td>
              </tr>
            <% end %>
            <%= if Enum.empty?(@episodes) do %>
              <tr>
                <td colspan="5" class="px-4 py-12 text-center text-gray-600">
                  No episodes yet. <.link patch={~p"/admin/seasons/#{@season.id}/episodes/new"} class="text-accent hover:underline">Add one →</.link>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp maybe_upload_video(socket, name) do
    case socket.assigns.uploads.video.entries do
      [] -> {:ok, nil}
      [entry | _] ->
        path =
          consume_uploaded_entry(socket, entry, fn %{path: tmp_path} ->
            filename = "#{System.unique_integer([:positive])}_#{entry.client_name}"
            dest = Path.join([@upload_dir, "videos", filename])
            File.cp!(tmp_path, dest)
            {:ok, dest}
          end)

        MediaCatalog.create_media_file(%{
          name: name,
          path: path,
          size: entry.client_size,
          type: entry.client_type
        })
    end
  end
end
