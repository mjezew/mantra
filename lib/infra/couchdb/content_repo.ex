defmodule Infra.CouchDB.ContentRepo do
  @behaviour Mantra.Contents.ContentRepo
  alias Ecto.Changeset
  alias Infra.CouchDB
  alias Mantra.Contents.Page

  @impl Mantra.Contents.ContentRepo
  def get_page_by(:id, page_id) do
    case CouchDB.Documents.get_document("blocks", page_id) do
      {:ok, %{status: 404}} ->
        nil

      {:ok, %{status: 200, body: doc}} ->
        doc = movekeys(doc, [{"_rev", "rev"}, {"_id", "id"}])
        Ecto.embedded_load(Page, doc, :atoms)
    end
  end

  @impl Mantra.Contents.ContentRepo
  def create_page(page_changeset) do
    with {:ok, page} <- Changeset.apply_action(page_changeset, :insert) do
      page_id = Slug.slugify(page.title, lowercase: false, separator: "__")

      case CouchDB.Documents.create_document("blocks", page_id, prepare_doc(page)) do
        {:ok, %{status: 201, body: doc}} ->
          doc =
            doc
            |> Map.take(["rev", "id"])
            |> movekeys([{"rev", :rev}, {"id", :id}])

          {:ok, Map.merge(page, Map.take(doc, [:id, :rev]))}

        {:ok, %{status: 409}} ->
          {:error, Changeset.add_error(page_changeset, :title, "is already taken")}
      end
    end
  end

  ## HELPERS
  # TODO: Probably repeated Doc -> model -> Doc code that can be abstracted eventually
  defp prepare_doc(%Page{} = page) do
    page
    |> Ecto.embedded_dump(:json)
    |> Map.put(:document_type, "page")
    |> Map.drop([:id])
  end

  defp movekeys(map, keys) do
    Enum.reduce(keys, map, fn {key, new_key}, acc ->
      {value, acc} = Map.pop(acc, key)
      Map.put(acc, new_key, value)
    end)
  end
end
