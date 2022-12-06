defmodule Infra.CouchDB.DocumentConflict do
  defexception [:document_id, :message]

  def exception(opts) do
    %__MODULE__{
      document_id: Keyword.fetch!(opts, :document_id),
      message: "Document update conflict"
    }
  end
end

defmodule Infra.CouchDB.Unauthorized do
  defexception [:message]
end

defmodule Infra.CouchDB.NotFound do
  defexception [:message]
end

defmodule Infra.CouchDB.BadRequest do
  defexception [:message]
end

defmodule Infra.CouchDB.PreconditionFailed do
  defexception [:message]
end
