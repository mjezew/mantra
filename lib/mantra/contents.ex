defmodule Mantra.Contents do
  alias Mantra.Contents.Page
  defp contents_repo(), do: Application.get_env(:mantra, Mantra.Contents.ContentRepo)

  @doc """
  Creates a new Page.

  Page will fail to create if the title is not unique.
  """
  def create_page(params) do
    Page.create_changeset(%Page{}, params)
    |> contents_repo().create_page()
  end
end
