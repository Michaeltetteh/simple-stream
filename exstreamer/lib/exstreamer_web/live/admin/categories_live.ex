defmodule ExstreamerWeb.Admin.CategoriesLive do
  use ExstreamerWeb, :live_view

  alias Exstreamer.Category

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Categories")
     |> assign(:categories, Category.list_categories())
     |> assign(:form, nil)
     |> assign(:editing, nil),
     layout: {ExstreamerWeb.Layouts, :admin}}
  end

  @impl true
  def handle_params(%{"id" => id}, _uri, %{assigns: %{live_action: :edit}} = socket) do
    cat = Category.get_category!(id)
    {:noreply,
     socket
     |> assign(:editing, cat)
     |> assign(:form, to_form(Category.change_category(cat)))}
  end

  def handle_params(_params, _uri, %{assigns: %{live_action: :new}} = socket) do
    {:noreply,
     socket
     |> assign(:editing, nil)
     |> assign(:form, to_form(Category.change_category(%Exstreamer.MediaCatalog.Category{})))}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket |> assign(:form, nil) |> assign(:editing, nil)}
  end

  @impl true
  def handle_event("save", %{"category" => params}, socket) do
    result =
      case socket.assigns.editing do
        nil -> Category.create_category(params)
        cat -> Category.update_category(cat, params)
      end

    case result do
      {:ok, _} ->
        {:noreply,
         socket
         |> put_flash(:info, "Category saved.")
         |> assign(:categories, Category.list_categories())
         |> push_patch(to: ~p"/admin/categories")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end

  def handle_event("delete", %{"id" => id}, socket) do
    cat = Category.get_category!(id)
    Category.delete_category(cat)
    {:noreply,
     socket
     |> put_flash(:info, "Category deleted.")
     |> assign(:categories, Category.list_categories())}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between mb-6">
        <h2 class="text-xl font-bold text-white">Categories</h2>
        <.link patch={~p"/admin/categories/new"}
              class="inline-flex items-center gap-2 bg-accent text-white text-sm font-semibold px-4 py-2 rounded-lg hover:bg-red-700 transition-colors">
          <.icon name="hero-plus-mini" class="w-4 h-4"/> Add Category
        </.link>
      </div>

      <%= if @form do %>
        <.modal id="category-modal" show on_cancel={JS.patch(~p"/admin/categories")}>
          <h3 class="text-lg font-bold text-white mb-4">
            <%= if @editing, do: "Edit Category", else: "New Category" %>
          </h3>
          <.simple_form for={@form} phx-submit="save" class="space-y-4">
            <.input field={@form[:name]} label="Name" placeholder="e.g. Action, Comedy..."/>
            <:actions>
              <.button type="submit" class="bg-accent hover:bg-red-700 text-white">Save</.button>
              <.link patch={~p"/admin/categories"} class="text-sm text-gray-400 ml-3">Cancel</.link>
            </:actions>
          </.simple_form>
        </.modal>
      <% end %>

      <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-3">
        <%= for cat <- @categories do %>
          <div class="bg-gray-850 rounded-xl border border-gray-800 p-4 flex items-center justify-between gap-2">
            <span class="font-medium text-white truncate"><%= cat.name %></span>
            <div class="flex items-center gap-2 flex-shrink-0">
              <.link patch={~p"/admin/categories/#{cat.id}/edit"} class="text-gray-500 hover:text-gray-300 transition-colors">
                <.icon name="hero-pencil-mini" class="w-4 h-4"/>
              </.link>
              <button phx-click="delete" phx-value-id={cat.id}
                      data-confirm={"Delete #{cat.name}?"}
                      class="text-gray-600 hover:text-red-500 transition-colors">
                <.icon name="hero-trash-mini" class="w-4 h-4"/>
              </button>
            </div>
          </div>
        <% end %>
        <%= if Enum.empty?(@categories) do %>
          <div class="col-span-full py-12 text-center text-gray-600">
            No categories yet. <.link patch={~p"/admin/categories/new"} class="text-accent hover:underline">Add one →</.link>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
