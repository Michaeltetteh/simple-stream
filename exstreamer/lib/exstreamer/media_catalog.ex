defmodule Exstreamer.MediaCatalog do
  @moduledoc """
  The MediaCatalog context.
  """

  import Ecto.Query, warn: false
  alias Exstreamer.Repo

  alias Exstreamer.MediaCatalog.Catalog
  alias Exstreamer.MediaCatalog.Category


  @doc """
  Returns the list of catalogs.

  ## Examples

      iex> list_catalogs()
      [%Catalog{}, ...]

  """
  def list_catalogs do
    Repo.all(Catalog)
  end

  @doc """
  Gets a single catalog.

  Raises `Ecto.NoResultsError` if the Catalog does not exist.

  ## Examples

      iex> get_catalog!(123)
      %Catalog{}

      iex> get_catalog!(456)
      ** (Ecto.NoResultsError)

  """
  def get_catalog!(id), do: Repo.get!(Catalog, id)

  @doc """
  Creates a catalog.

  ## Examples

      iex> create_catalog(%{field: value})
      {:ok, %Catalog{}}

      iex> create_catalog(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_catalog(attrs \\ %{}) do
    %Catalog{}
    |> Catalog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a catalog.

  ## Examples

      iex> update_catalog(catalog, %{field: new_value})
      {:ok, %Catalog{}}

      iex> update_catalog(catalog, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_catalog(%Catalog{} = catalog, attrs) do
    catalog
    |> Catalog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a catalog.

  ## Examples

      iex> delete_catalog(catalog)
      {:ok, %Catalog{}}

      iex> delete_catalog(catalog)
      {:error, %Ecto.Changeset{}}

  """
  def delete_catalog(%Catalog{} = catalog) do
    Repo.delete(catalog)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking catalog changes.

  ## Examples

      iex> change_catalog(catalog)
      %Ecto.Changeset{data: %Catalog{}}

  """
  def change_catalog(%Catalog{} = catalog, attrs \\ %{}) do
    Catalog.changeset(catalog, attrs)
  end



  #Category
  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Repo.all(Category)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)


  @doc """
  Gets category by name
  """
  def get_category_by_name(name) do 
    Repo.get_by(Category, name: name) 
  end


  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs \\ %{}) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end
end
