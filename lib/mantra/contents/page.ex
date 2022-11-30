defmodule Mantra.Contents.Page do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          title: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  embedded_schema do
    # TODO uniqueness here
    field :title, :string
    timestamps()
  end

  def from_graph(params) do
    %__MODULE__{}
    |> cast(params, [:id, :title])
    |> apply_changes()
  end

  def create_changeset(struct, params) do
    struct
    |> cast(params, [:title])
    |> validate_required(:title)
  end
end
