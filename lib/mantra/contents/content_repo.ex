defmodule Mantra.Contents.ContentRepo do
  alias Ecto.Changeset
  alias Mantra.Contents.Page

  @callback create_page(Changeset.t(Page.t())) ::
              {:ok, Page.t()} | {:error, Changeset.t(Page.t())}
end
