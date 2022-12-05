defmodule Mantra.Contents.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          state: :todo | :waiting | :done | :cancelled,
          scheduled: DateTime.t() | nil,
          deadline: DateTime.t() | nil
        }

  @primary_key false
  embedded_schema do
    field :state, Ecto.Enum, values: [:todo, :waiting, :done, :cancelled]
    field :scheduled, :utc_datetime
    field :deadline, :utc_datetime
  end

  def changeset(todo, params \\ %{}) do
    todo
    |> cast(params, [:state, :scheduled, :deadline])
    |> validate_required([:state])
  end
end
