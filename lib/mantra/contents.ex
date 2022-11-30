defmodule Mantra.Contents do
  alias Mantra.Contents.{Block, Page}
  defp contents_repo(), do: Application.get_env(:mantra, Mantra.Contents.Repo)

  def create_page(_user, title) do
    case contents_repo().get_page_by(:title, title) do
      %Page{} -> {:error, :page_already_exists}
      nil -> contents_repo().create_page(Page.create_changeset(%Page{}, %{title: title}))
    end
  end

  def add_block_to_page(page_id, params) do
    with %Page{} = page <- contents_repo().get_page_by(:id, page_id) do
      contents_repo().add_block_to_page(page, Block.create_changeset(%Block{}, params))
    end
  end

  def add_block_to_block(block_id, params) do
    with %Block{} = block <- contents_repo().get_block_by(:id, block_id) do
      contents_repo().add_block_to_block(block, Block.create_changeset(%Block{}, params))
    end
  end
end
