defmodule Infra.CouchDB.ContentRepo do
  @behaviour Mantra.Contents.ContentRepo
  alias Ecto.Changeset
  alias Infra.CouchDB
  alias Infra.CouchDB.Client
  alias Mantra.Contents.{Block, Page}

  @impl Mantra.Contents.ContentRepo
  def get_page_by(:id, page_id) do
    with {:ok, doc} <- Client.get("/blocks/#{page_id}") do
      doc = movekeys(doc, [{"_rev", "rev"}, {"_id", "id"}])
      Ecto.embedded_load(Page, doc, :atoms)
    end
  end

  @impl Mantra.Contents.ContentRepo
  def create_page(page_changeset) do
    with {:ok, page} <- Changeset.apply_action(page_changeset, :insert) do
      page_id = Slug.slugify(page.title, lowercase: false, separator: "__")

      case Client.put("/blocks/#{page_id}", prepare_doc(page)) do
        {:ok, doc} ->
          doc =
            doc
            |> Map.take(["rev", "id"])
            |> movekeys([{"rev", :rev}, {"id", :id}])

          {:ok, Map.merge(page, Map.take(doc, [:id, :rev]))}

        {:error, %CouchDB.DocumentConflict{}} ->
          {:error, Changeset.add_error(page_changeset, :title, "is already taken")}
      end
    end
  end

  @impl Mantra.Contents.ContentRepo
  def get_block_by(:id, block_id) do
    case Client.get("/blocks/#{block_id}") do
      {:error, %CouchDB.NotFound{}} ->
        nil

      {:ok, doc} ->
        doc = movekeys(doc, [{"_id", "id"}, {"_rev", "rev"}])
        Ecto.embedded_load(Block, doc, :atoms)
    end
  end

  @impl Mantra.Contents.ContentRepo
  def add_block_to_page(page, block_changeset) do
    with {:ok, block} <- Changeset.apply_action(block_changeset, :insert) do
      block_id = "#{page.id}-#{Nanoid.generate()}"

      case Client.put("/blocks/#{block_id}", prepare_doc(block)) do
        {:ok, doc} ->
          doc =
            doc
            |> Map.take(["rev", "id"])
            |> movekeys([{"rev", :rev}, {"id", :id}])

          {:ok, Map.merge(block, Map.take(doc, [:id, :rev]))}

        # TODO: Error handling
        error ->
          IO.inspect(error)
          {:error, Changeset.add_error(block_changeset, :id, "cannot be created")}
      end
    end
  end

  @impl Mantra.Contents.ContentRepo
  def add_block_to_block(parent_block, block_changeset) do
    with {:ok, new_block} <- Changeset.apply_action(block_changeset, :insert) do
      page_id = List.last(parent_block.ancestors)
      block_id = "#{page_id}-#{Nanoid.generate()}"

      case Client.put("/blocks/#{block_id}", prepare_doc(new_block)) do
        {:ok, doc} ->
          doc =
            doc
            |> Map.take(["rev", "id"])
            |> movekeys([{"rev", :rev}, {"id", :id}])

          {:ok, Map.merge(new_block, Map.take(doc, [:id, :rev]))}

        # TODO: Error handling
        error ->
          IO.inspect(error)
          {:error, Changeset.add_error(block_changeset, :id, "cannot be created")}
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

  defp prepare_doc(%Block{} = block) do
    block
    |> Ecto.embedded_dump(:json)
    |> Map.put(:document_type, "block")
    |> Map.drop([:id])
  end

  defp movekeys(map, keys) do
    Enum.reduce(keys, map, fn {key, new_key}, acc ->
      {value, acc} = Map.pop(acc, key)
      Map.put(acc, new_key, value)
    end)
  end
end
