defmodule Mantra.Contents.Block do
  use Ecto.Schema
  import Ecto.Changeset
  alias Mantra.Contents.{Link, Todo}

  @type t :: %__MODULE__{
          id: String.t(),
          rev: String.t(),
          content: String.t(),
          ancestors: [String.t()],
          links: [Link.t()],
          position: String.t(),
          todo: Todo.t() | nil
        }

  embedded_schema do
    field :rev, :string
    field :content, :string
    field :ancestors, {:array, :string}
    field :links, {:array, :string}
    field :position, :string
    embeds_one :todo, Todo, on_replace: :update
  end

  def create_changeset(block, params \\ %{}) do
    block
    |> cast(params, [:content, :ancestors, :position])
    |> validate_required([:content, :ancestors, :position])
    |> put_links()
    |> cast_embed(:todo)
  end

  def put_links(%Ecto.Changeset{valid?: false} = invalid_changeset), do: invalid_changeset

  def put_links(%Ecto.Changeset{valid?: true} = changeset) do
    content = get_field(changeset, :content)
    put_change(changeset, :links, Link.parse_links(content))
  end
end
