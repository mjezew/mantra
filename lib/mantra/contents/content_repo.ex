defmodule Mantra.Contents.ContentRepo do
  alias Ecto.Changeset
  alias Mantra.Contents.{Block, Page}

  @callback create_page(Changeset.t(Page.t())) ::
              {:ok, Page.t()} | {:error, Changeset.t(Page.t())}

  @callback get_page_by(:id, page_id :: String.t()) :: Page.t() | nil

  @callback add_block_to_page(Page.t(), Changeset.t(Block.t())) ::
              {:ok, Block.t()} | {:error, Changeset.t(Block.t())}

  @callback get_block_by(:id, block_id :: String.t()) :: Block.t() | nil

  @callback add_block_to_block(Block.t(), Changeset.t(Block.t())) ::
              {:ok, Block.t()} | {:error, Changeset.t(Block.t())}
end
