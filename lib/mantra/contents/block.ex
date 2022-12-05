defmodule Mantra.Contents.Block do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mantra.Contents.Todo

  @type t :: %__MODULE__{
          id: String.t(),
          rev: String.t(),
          content: String.t(),
          ancestors: [String.t()],
          position: String.t(),
          todo: Todo.t() | nil
        }

  embedded_schema do
    field :rev, :string
    field :content, :string
    field :ancestors, {:array, :string}
    field :position, :string
    embeds_one :todo, Todo, on_replace: :update
  end

  def create_changeset(block, params \\ %{}) do
    block
    |> cast(params, [:content, :ancestors, :position])
    |> validate_required([:content, :ancestors, :position])
    |> cast_embed(:todo)
  end
end
