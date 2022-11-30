defmodule Mantra.Contents.BelongsTo do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.UUID, autogenerate: true}
  embedded_schema do
    timestamps()
  end

  def from_graph(params) do
    %__MODULE__{}
    |> cast(params, [])
    |> apply_changes()
  end
end
