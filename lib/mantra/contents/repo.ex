defmodule Mantra.Contents.Repo do
  alias Mantra.Contents.{Block, Page}

  @callback get_page_by(key :: :title | :id, title :: String.t()) :: Page.t() | nil
  @callback create_page(changeset :: Ecto.Changeset.t(Page.t())) ::
              {:ok, Page.t()} | {:error, Ecto.Changeset.t(Page.t())}
  @callback add_block_to_page(page :: Page.t(), params :: Ecto.Changeset.t(Block.t())) ::
              {:ok, Page.t()} | {:error, Ecto.Changeset.t(Block.t())}
  @callback add_block_to_block(block :: Block.t(), params :: Ecto.Changeset.t(Block.t())) ::
              {:ok, Block.t()} | {:error, Ecto.Changeset.t(Block.t())}
end
