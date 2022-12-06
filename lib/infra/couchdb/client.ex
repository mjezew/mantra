defmodule Infra.CouchDB.Client do
  alias Infra.CouchDB

  @middleware [
    # TODO: Pull from environment when hardened
    {Tesla.Middleware.BaseUrl, "http://localhost:5984"},
    {Tesla.Middleware.BasicAuth, username: "couchdb", password: "password"},
    Tesla.Middleware.JSON
  ]

  def put(url, doc, opts \\ []) do
    client()
    |> Tesla.put(url, doc, opts)
    |> case do
      {:ok, %{status: 400, body: %{"reason" => reason}}} ->
        {:error, CouchDB.BadRequest.exception(reason)}

      {:ok, %{status: 401, body: %{"reason" => reason}}} ->
        {:error, CouchDB.Unauthorized.exception(reason)}

      {:ok, %{status: 412, body: %{"reason" => reason}}} ->
        {:error, CouchDB.PreconditionFailed.exception(reason)}

      {:ok, %{body: body}} ->
        {:ok, body}
    end
  end

  def get(url, opts \\ []) do
    client()
    |> Tesla.get(url, opts)
    |> case do
      {:ok, %{status: 400, body: %{"reason" => reason}}} ->
        {:error, CouchDB.BadRequest.exception(reason)}

      {:ok, %{status: 401, body: %{"reason" => reason}}} ->
        {:error, CouchDB.Unauthorized.exception(reason)}

      {:ok, %{status: 404, body: %{"reason" => reason}}} ->
        {:error, CouchDB.NotFound.exception(reason)}

      {:ok, %{body: body}} ->
        {:ok, body}
    end
  end

  defp client() do
    Tesla.client(@middleware)
  end
end
