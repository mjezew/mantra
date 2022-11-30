defmodule Mantra.Contents.Block do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          content: String.t(),
          order: non_neg_integer(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  embedded_schema do
    field :content, :string
    field :order, :integer
    timestamps()
  end

  def from_graph(params) do
    %__MODULE__{}
    |> cast(params, [:content, :order, :id])
    |> apply_changes()
  end

  def create_changeset(struct, params) do
    struct
    |> cast(params, [:content, :order])
    |> validate_required([:content, :order])
  end
end
