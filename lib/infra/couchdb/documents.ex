defmodule Infra.CouchDB.Documents do
  use Tesla

  # TODO: Pull from environment when hardened
  plug Tesla.Middleware.BaseUrl, "http://localhost:5984"
  plug Tesla.Middleware.BasicAuth, username: "couchdb", password: "password"
  plug Tesla.Middleware.JSON

  def create_document(database_name, doc_id, document) do
    put("/#{database_name}/#{doc_id}", document)
  end

  def get_document(database_name, doc_id) do
    get("/#{database_name}/#{doc_id}")
  end

  def update_doc(database_name, doc_id, document) do
    post("/#{database_name}/#{doc_id}", document)
  end
end
