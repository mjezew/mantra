defmodule Infra.CouchDB.ContentRepo do
  @behaviour Mantra.Contents.ContentRepo
  alias Ecto.Changeset
  alias Infra.CouchDB
  alias Mantra.Contents.Page

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
