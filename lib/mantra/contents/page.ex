defmodule Mantra.Contents.Page do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: String.t(),
          rev: String.t(),
          title: String.t()
        }

  embedded_schema do
    field :rev, :string
    field :title, :string
  end

  def create_changeset(page, params \\ %{}) do
    page
    |> cast(params, [:title])
    |> validate_required([:title])
  end
end
